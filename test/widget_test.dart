import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/core/validators.dart';

void main() {
  test('acepta un título de tarea', () {
    expect(validateTitle('Comprar café'), isNull);
  });
}
