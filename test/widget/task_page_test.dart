import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/data/repositories.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';
import 'package:practica_integracion_pruebas_flutter/models/task.dart';

class FakeTasks implements TaskRepository {
  final controller = StreamController<List<Task>>.broadcast();
  int saves = 0;
  @override Stream<List<Task>> watchTasks() => controller.stream;
  @override Future<void> save(Task task) async { saves++; }
  @override Future<void> delete(String id) async {}
}
class FakeAuth implements AuthRepository {
  @override Stream<String?> authState() => Stream.value('1');
  @override Future<void> signIn(String email, String password, {required bool register}) async {}
  @override Future<void> signOut() async {}
}
void main() {
  testWidgets('muestra carga y lista vacía', (tester) async {
    final repo = FakeTasks();
    await tester.pumpWidget(MaterialApp(home: TaskListPage(auth: FakeAuth(), repository: repo)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repo.controller.add([]);
    await tester.pump();
    expect(find.text('No hay tareas.'), findsOneWidget);
    await repo.controller.close();
  });
  testWidgets('impide guardar formulario vacío', (tester) async {
    final repo = FakeTasks();
    await tester.pumpWidget(MaterialApp(home: TaskFormPage(repository: repo)));
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('El título debe tener entre 3 y 80 caracteres.'), findsOneWidget);
    expect(repo.saves, 0);
    await repo.controller.close();
  });
}
