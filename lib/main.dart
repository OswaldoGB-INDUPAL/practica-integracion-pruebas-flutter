import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'data/notification_service.dart';
import 'core/validators.dart';
import 'data/repositories.dart';
import 'models/task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final navigatorKey = GlobalKey<NavigatorState>();
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  final notifications = NotificationService(
    navigatorKey,
    messengerKey,
    FirebaseTaskRepository.new,
  );
  try {
    await notifications.start();
  } catch (_) {
    debugPrint('No se pudieron iniciar las notificaciones.');
  }
  runApp(
    MyApp(
      auth: FirebaseAuthRepository(),
      tasks: FirebaseTaskRepository.new,
      notifications: notifications,
      navigatorKey: navigatorKey,
      messengerKey: messengerKey,
    ),
  );
}

class TaskRouteArguments {
  const TaskRouteArguments(this.repository, [this.task]);
  final TaskRepository repository;
  final Task? task;
}

Route<dynamic>? appRoute(RouteSettings settings) {
  final args = settings.arguments;
  if (args is! TaskRouteArguments) return null;
  if (settings.name == '/formulario') {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) =>
          TaskFormPage(repository: args.repository, task: args.task),
    );
  }
  if (settings.name == '/detalle' && args.task != null) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) =>
          TaskDetailPage(repository: args.repository, task: args.task!),
    );
  }
  return null;
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.auth,
    required this.tasks,
    this.notifications,
    this.navigatorKey,
    this.messengerKey,
  });
  final AuthRepository auth;
  final TaskRepository Function(String) tasks;
  final NotificationService? notifications;
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? messengerKey;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final fallbackNavigatorKey = GlobalKey<NavigatorState>();
  String? previousUid;
  bool seenSession = false;
  late final Stream<String?> session = widget.auth.authState().map((uid) {
    if (seenSession && uid != previousUid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          (widget.navigatorKey ?? fallbackNavigatorKey).currentState?.popUntil(
            (route) => route.isFirst,
          );
        }
      });
    }
    seenSession = true;
    previousUid = uid;
    widget.notifications?.setUser(uid);
    return uid;
  });
  @override
  void dispose() {
    widget.notifications?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: widget.navigatorKey ?? fallbackNavigatorKey,
    scaffoldMessengerKey: widget.messengerKey,
    onGenerateRoute: appRoute,
    title: 'Mis tareas',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: StreamBuilder<String?>(
      stream: session,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('No se pudo comprobar la sesión.')),
          );
        }
        final uid = snapshot.data;
        return uid == null
            ? LoginPage(auth: widget.auth)
            : TaskListPage(
                key: ValueKey(uid),
                auth: widget.auth,
                repository: widget.tasks(uid),
              );
      },
    ),
  );
}

void showFailure(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        error is AppException
            ? error.message
            : 'Ocurrió un error. Inténtalo de nuevo.',
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.auth});
  final AuthRepository auth;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(), password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit(bool register) async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await widget.auth.signIn(
        email.text.trim(),
        password.text,
        register: register,
      );
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mis tareas')),
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: form,
              child: Column(
                children: [
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Ingresa un correo válido.'
                        : null,
                  ),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (v) => v == null || v.length < 6
                        ? 'Ingresa al menos 6 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: busy ? null : () => submit(false),
                    child: const Text('Iniciar sesión'),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => submit(true),
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key, required this.auth, required this.repository});
  final AuthRepository auth;
  final TaskRepository repository;
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late final Stream<List<Task>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = widget.repository.watchTasks();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis tareas'),
      actions: [
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: () async {
            try {
              await widget.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            } catch (e) {
              if (context.mounted) showFailure(context, e);
            }
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.of(context).pushNamed(
        '/formulario',
        arguments: TaskRouteArguments(widget.repository),
      ),
      tooltip: 'Nueva tarea',
      child: const Icon(Icons.add),
    ),
    body: StreamBuilder<List<Task>>(
      stream: tasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('No se pudieron cargar las tareas.'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const Center(child: Text('No hay tareas.'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final task = items[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.done ? 'Completada' : 'Pendiente'),
              onTap: () => Navigator.of(context).pushNamed(
                '/detalle',
                arguments: TaskRouteArguments(widget.repository, task),
              ),
            );
          },
        );
      },
    ),
  );
}

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, required this.repository, this.task});
  final TaskRepository repository;
  final Task? task;
  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController title, description;
  late bool done;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.task?.title);
    description = TextEditingController(text: widget.task?.description);
    done = widget.task?.done ?? false;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final old = widget.task;
    final text = title.text.trim();
    if (old != null &&
        old.title == text &&
        old.description == description.text &&
        old.done == done) {
      Navigator.pop(context, 'Sin cambios');
      return;
    }
    setState(() => busy = true);
    try {
      await widget.repository.save(
        Task(
          id: old?.id ?? '',
          title: text,
          description: description.text,
          done: done,
          createdAt: old?.createdAt ?? DateTime.now(),
        ),
      );
      if (mounted) Navigator.pop(context, 'Tarea guardada');
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.task == null ? 'Nueva tarea' : 'Editar tarea'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: form,
        child: ListView(
          children: [
            TextFormField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: validateTitle,
            ),
            TextFormField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 4,
              validator: validateDescription,
            ),
            SwitchListTile(
              title: const Text('Completada'),
              value: done,
              onChanged: (value) => setState(() => done = value),
            ),
            FilledButton(
              onPressed: busy ? null : save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    ),
  );
}

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({
    super.key,
    required this.repository,
    required this.task,
  });
  final TaskRepository repository;
  final Task task;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalle')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          Text(task.description),
          Text(task.done ? 'Completada' : 'Pendiente'),
          FilledButton(
            onPressed: () async {
              final result = await Navigator.pushNamed<String>(
                context,
                '/formulario',
                arguments: TaskRouteArguments(repository, task),
              );
              if (!context.mounted) return;
              if (result != null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result)));
              }
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Eliminar tarea?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              try {
                await repository.delete(task.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) showFailure(context, e);
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ),
  );
}
