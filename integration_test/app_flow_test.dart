import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';
import '../test/widget/task_page_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('crear tarea desde el formulario', (tester) async {
    final repo = FakeTasks();
    await tester.pumpWidget(MaterialApp(home: TaskFormPage(repository: repo)));
    await tester.enterText(find.widgetWithText(TextFormField, 'Título'), 'Comprar café');
    await tester.enterText(find.widgetWithText(TextFormField, 'Descripción'), 'Dos libras');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(repo.saves, 1);
    await repo.controller.close();
  });
}
