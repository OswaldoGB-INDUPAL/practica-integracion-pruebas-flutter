import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/data/repositories.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';
import 'package:practica_integracion_pruebas_flutter/models/task.dart';

class SessionFake implements AuthRepository {
  final events = StreamController<String?>.broadcast();
  int attempts = 0;
  @override
  Stream<String?> authState() => events.stream;
  @override
  Future<void> signIn(
    String email,
    String password, {
    required bool register,
  }) async {
    attempts++;
    throw const AppException('Credenciales inválidas.');
  }

  @override
  Future<void> signOut() async {
    events.add(null);
  }
}

class TaskFake implements TaskRepository {
  final events = StreamController<List<Task>>.broadcast();
  final List<Task> saved = [];
  final List<String> deleted = [];
  @override
  Stream<List<Task>> watchTasks() => events.stream;
  @override
  Future<void> save(Task task) async {
    saved.add(task);
  }

  @override
  Future<void> delete(String id) async {
    deleted.add(id);
  }
}

void main() {
  testWidgets('CP-03: muestra error de credenciales rechazadas', (
    tester,
  ) async {
    final auth = SessionFake();
    await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo'),
      'prueba1@test.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'incorrecta',
    );
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(auth.attempts, 1);
    expect(find.text('Credenciales inválidas.'), findsOneWidget);
    await auth.events.close();
  });
  testWidgets('CP-06: regresar del formulario vuelve a la lista', (
    tester,
  ) async {
    final auth = SessionFake();
    final repo = TaskFake();
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: appRoute,
        home: TaskListPage(auth: auth, repository: repo),
      ),
    );
    repo.events.add([]);
    await tester.pump();
    await tester.tap(find.byTooltip('Nueva tarea'));
    await tester.pumpAndSettle();
    expect(find.text('Nueva tarea'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repo.events.close();
    await auth.events.close();
  });
  testWidgets('CP-09: editar guarda valores cambiados', (tester) async {
    final repo = TaskFake();
    final task = Task(
      id: '1',
      title: 'Café',
      description: '',
      done: false,
      createdAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskFormPage(repository: repo, task: task),
              ),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      'Comprar café',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(repo.saved.single.title, 'Comprar café');
    expect(repo.saved.single.id, '1');
    await repo.events.close();
  });
  testWidgets('CP-10: eliminar requiere confirmación', (tester) async {
    final repo = TaskFake();
    final task = Task(
      id: '1',
      title: 'Café',
      description: '',
      done: false,
      createdAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(repository: repo, task: task),
      ),
    );
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(repo.deleted, isEmpty);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repo.deleted, isEmpty);
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();
    expect(repo.deleted, ['1']);
    await repo.events.close();
  });
  testWidgets('CP-12: error de lectura muestra mensaje', (tester) async {
    final auth = SessionFake();
    final repo = TaskFake();
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: appRoute,
        home: TaskListPage(auth: auth, repository: repo),
      ),
    );
    repo.events.addError(const AppException('Sin conexión'));
    await tester.pump();
    expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repo.events.close();
    await auth.events.close();
  });
  testWidgets('INC-001: caducidad de sesión cierra detalles privados', (
    tester,
  ) async {
    final auth = SessionFake();
    final repo = TaskFake();
    await tester.pumpWidget(MyApp(auth: auth, tasks: (_) => repo));
    auth.events.add('usuario1');
    await tester.pump();
    await tester.pump();
    final task = Task(
      id: '1',
      title: 'Dato privado',
      description: '',
      done: false,
      createdAt: DateTime.utc(2026),
    );
    repo.events.add([task]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dato privado'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsOneWidget);
    auth.events.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Dato privado'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await repo.events.close();
    await auth.events.close();
  });
}
