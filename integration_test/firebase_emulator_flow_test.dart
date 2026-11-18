import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:practica_integracion_pruebas_flutter/data/repositories.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  String stage = '',
}) async {
  for (var i = 0; i < 200; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
      return;
    }
  }
  final visible = tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data)
      .whereType<String>()
      .take(20)
      .toList();
  throw TestFailure(
    'No apareció el elemento esperado en $stage: $finder; sesión activa: ${FirebaseAuth.instance.currentUser != null}; textos visibles: $visible',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'registro, creación, edición, eliminación y cierre con emuladores Firebase',
    (tester) async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-api-key',
          appId: '1:123456789:web:demo',
          messagingSenderId: '123456789',
          projectId: 'demo-semana16',
          authDomain: 'demo-semana16.firebaseapp.com',
        ),
      );
      await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8094);
      await FirebaseAuth.instance.signOut();

      final email = 'prueba${DateTime.now().microsecondsSinceEpoch}@test.com';
      await tester.pumpWidget(
        MyApp(
          auth: FirebaseAuthRepository(),
          tasks: FirebaseTaskRepository.new,
        ),
      );
      await waitFor(tester, find.text('Crear cuenta'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'secreto123',
      );
      await tester.tap(find.text('Crear cuenta'));
      await waitFor(tester, find.byTooltip('Nueva tarea'));
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await tester.tap(find.byTooltip('Nueva tarea'));
      await waitFor(tester, find.text('Guardar'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Comprar café',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Descripción'),
        'Dos libras',
      );
      await tester.tap(find.text('Guardar'));
      await waitFor(tester, find.widgetWithText(ListTile, 'Comprar café'));
      var stored = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();
      expect(stored.docs, hasLength(1));
      expect(stored.docs.single.data()['title'], 'Comprar café');
      await tester.tap(find.widgetWithText(ListTile, 'Comprar café'));
      await waitFor(tester, find.text('Editar'));
      await tester.tap(find.text('Editar'));
      await waitFor(tester, find.text('Guardar'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Comprar té',
      );
      await tester.tap(find.text('Guardar'));
      await waitFor(tester, find.widgetWithText(ListTile, 'Comprar té'));
      stored = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();
      expect(stored.docs.single.data()['title'], 'Comprar té');
      await tester.tap(find.widgetWithText(ListTile, 'Comprar té'));
      await waitFor(tester, find.text('Eliminar'));
      await tester.tap(find.text('Eliminar'));
      await waitFor(tester, find.text('Cancelar'));
      await tester.tap(find.text('Eliminar').last);
      await waitFor(tester, find.text('No hay tareas.'));
      stored = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();
      expect(stored.docs, isEmpty);
      await tester.tap(find.byTooltip('Nueva tarea'));
      await waitFor(tester, find.text('Guardar'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Tarea persistente',
      );
      await tester.tap(find.text('Guardar'));
      await waitFor(
        tester,
        find.widgetWithText(ListTile, 'Tarea persistente'),
        stage: 'creación',
      );
      await tester.tap(find.byTooltip('Cerrar sesión'));
      await waitFor(tester, find.text('Iniciar sesión'));
      expect(FirebaseAuth.instance.currentUser, isNull);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'incorrecta',
      );
      await tester.tap(find.text('Iniciar sesión'));
      await waitFor(
        tester,
        find.text(
          'No se pudo iniciar la sesión o registrar la cuenta. Revisa los datos.',
        ),
      );
      expect(FirebaseAuth.instance.currentUser, isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MyApp(
          auth: FirebaseAuthRepository(),
          tasks: FirebaseTaskRepository.new,
        ),
      );
      await waitFor(tester, find.text('Iniciar sesión'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'secreto123',
      );
      await tester.pump();
      expect(
        tester
            .widget<TextFormField>(find.widgetWithText(TextFormField, 'Correo'))
            .controller!
            .text,
        email,
      );
      expect(
        tester
            .widget<TextFormField>(
              find.widgetWithText(TextFormField, 'Contraseña'),
            )
            .controller!
            .text,
        'secreto123',
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Iniciar sesión'),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.text('Iniciar sesión'));
      await waitFor(
        tester,
        find.widgetWithText(ListTile, 'Tarea persistente'),
        stage: 'reingreso',
      );
      expect(FirebaseAuth.instance.currentUser!.uid, uid);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MyApp(
          auth: FirebaseAuthRepository(),
          tasks: FirebaseTaskRepository.new,
        ),
      );
      await waitFor(
        tester,
        find.widgetWithText(ListTile, 'Tarea persistente'),
        stage: 'reconstrucción',
      );
      await tester.tap(find.byTooltip('Cerrar sesión'));
      await waitFor(tester, find.text('Iniciar sesión'));
      expect(FirebaseAuth.instance.currentUser, isNull);
    },
  );
}
