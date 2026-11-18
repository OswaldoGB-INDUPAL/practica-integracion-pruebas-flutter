import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/models/task.dart';

void main() {
  test('conserva los campos al convertir a mapa y volver', () {
    final date = DateTime.utc(2026, 1, 1);
    final task = Task(
      id: '1',
      title: 'Comprar café',
      description: 'Dos libras',
      done: true,
      createdAt: date,
    );
    final restored = Task.fromMap('1', task.toMap());
    expect(restored.title, task.title);
    expect(restored.description, task.description);
    expect(restored.done, isTrue);
    expect(restored.createdAt, date);
  });
  test('proporciona valores seguros para campos ausentes', () {
    final task = Task.fromMap('1', {});
    expect(task.title, '');
    expect(task.description, '');
    expect(task.done, isFalse);
  });
}
