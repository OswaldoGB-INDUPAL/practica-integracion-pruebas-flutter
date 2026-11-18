import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/data/notification_service.dart';

void main() {
  test('elimina solo el token del dispositivo actual', () async {
    final db = FakeFirebaseFirestore();
    final user = db.collection('users').doc('u1');
    await user.set({'fcmToken': 'token-actual', 'nombre': 'Prueba'});
    await removeTokenIfMatching(db, 'u1', 'token-actual');
    expect((await user.get()).data(), {'nombre': 'Prueba'});
  });
  test('no elimina el token registrado por otro dispositivo', () async {
    final db = FakeFirebaseFirestore();
    final user = db.collection('users').doc('u1');
    await user.set({'fcmToken': 'token-otro'});
    await removeTokenIfMatching(db, 'u1', 'token-actual');
    expect((await user.get()).data(), {'fcmToken': 'token-otro'});
  });
  test('no crea un documento de usuario inexistente', () async {
    final db = FakeFirebaseFirestore();
    await removeTokenIfMatching(db, 'u1', 'token-actual');
    expect((await db.collection('users').doc('u1').get()).exists, isFalse);
  });
}
