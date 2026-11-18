import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/data/repositories.dart';

class AuthFake implements FirebaseAuth {
  final List<String> calls;
  AuthFake(this.calls);
  @override
  Future<void> signOut() async => calls.add('auth');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('limpia las notificaciones antes de cerrar Firebase Auth', () async {
    final calls = <String>[];
    final auth = FirebaseAuthRepository(
      auth: AuthFake(calls),
      beforeSignOut: () async {
        calls.add('token');
      },
    );
    await auth.signOut();
    expect(calls, ['token', 'auth']);
  });
  test('permite cerrar sesión cuando falla la limpieza sin conexión', () async {
    final calls = <String>[];
    final auth = FirebaseAuthRepository(
      auth: AuthFake(calls),
      beforeSignOut: () async {
        calls.add('token');
        throw Exception('sin conexión');
      },
    );
    await auth.signOut();
    expect(calls, ['token', 'auth']);
  });
}
