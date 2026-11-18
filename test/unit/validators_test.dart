import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/core/validators.dart';

void main() {
  test('valida límites y espacios del título', () {
    expect(validateTitle(''), isNotNull);
    expect(validateTitle('  '), isNotNull);
    expect(validateTitle('ab'), isNotNull);
    expect(validateTitle('a' * 81), isNotNull);
    expect(validateTitle('Comprar café'), isNull);
  });
  test('limita la descripción a 500 caracteres', () {
    expect(validateDescription('a' * 500), isNull);
    expect(validateDescription('a' * 501), isNotNull);
  });
}
