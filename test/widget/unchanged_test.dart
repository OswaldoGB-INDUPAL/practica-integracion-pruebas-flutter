import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';
import 'package:practica_integracion_pruebas_flutter/models/task.dart';
import 'task_page_test.dart';

void main() {
  testWidgets('al guardar sin cambios vuelve y no escribe', (tester) async {
    final repo = FakeTasks();
    final task = Task(
      id: '1',
      title: 'Comprar café',
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
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(repo.saves, 0);
    expect(find.text('Abrir'), findsOneWidget);
    await repo.controller.close();
  });
}
