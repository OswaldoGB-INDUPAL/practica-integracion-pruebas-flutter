import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/data/repositories.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';
import 'package:practica_integracion_pruebas_flutter/models/task.dart';

class FakeAuth implements AuthRepository {
  final controller = StreamController<String?>.broadcast();
  @override
  Stream<String?> authState() => controller.stream;
  @override
  Future<void> signIn(
    String email,
    String password, {
    required bool register,
  }) async => controller.add('test-user');
  @override
  Future<void> signOut() async => controller.add(null);
}

class FakeTasks implements TaskRepository {
  final controller = StreamController<List<Task>>.broadcast();
  final List<Task> items = [];
  @override
  Stream<List<Task>> watchTasks() async* {
    yield List.of(items);
    yield* controller.stream;
  }

  @override
  Future<void> save(Task task) async {
    items.add(
      Task(
        id: task.id.isEmpty ? 'fake-task-1' : task.id,
        title: task.title,
        description: task.description,
        done: task.done,
        createdAt: task.createdAt,
      ),
    );
    controller.add(List.of(items));
  }

  @override
  Future<void> delete(String id) async {
    items.removeWhere((task) => task.id == id);
    controller.add(List.of(items));
  }
}

void registerAppFlowTest() {
  testWidgets(
    'iniciar sesión, crear tarea y cerrar sesión con repositorios fake',
    (tester) async {
      final auth = FakeAuth();
      final tasks = FakeTasks();
      await tester.pumpWidget(MyApp(auth: auth, tasks: (_) => tasks));
      auth.controller.add(null);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'prueba1@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'secreto123',
      );
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Nueva tarea'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Comprar café',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Descripción'),
        'Dos libras',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Comprar café'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Comprar café'));
      await tester.pumpAndSettle();
      final detail = tester.widget<TaskDetailPage>(find.byType(TaskDetailPage));
      expect(detail.task.id, 'fake-task-1');
      expect(detail.task.description, 'Dos libras');
      expect(find.text('Dos libras'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Comprar café'), findsOneWidget);
      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Comprar café'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await auth.controller.close();
      await tasks.controller.close();
    },
  );
}
