import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:practica_integracion_pruebas_flutter/data/notification_service.dart';
import '../widget/notification_navigation_test.dart';

class CleanupFake extends NotificationService {
  CleanupFake(NotificationTasks tasks)
    : super(
        GlobalKey<NavigatorState>(),
        GlobalKey<ScaffoldMessengerState>(),
        (_) => tasks,
      );
  int calls = 0;
  Completer<void>? pendingCleanup;
  @override
  Future<void> prepareSignOut() async {
    calls++;
    uid = null;
    await pendingCleanup?.future;
  }
}

void main() {
  test('la caducidad de sesión también inicia la limpieza FCM', () async {
    final repo = NotificationTasks();
    final service = CleanupFake(repo)..uid = 'usuario-a';
    await service.setUser(null);
    expect(service.calls, 1);
    expect(service.uid, isNull);
    await repo.controller.close();
  });
  test(
    'la primera emisión sin sesión no limpia un token inexistente',
    () async {
      final repo = NotificationTasks();
      final service = CleanupFake(repo);
      await service.setUser(null);
      expect(service.calls, 0);
      await repo.controller.close();
    },
  );
  test('el siguiente inicio espera la limpieza anterior', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final repo = NotificationTasks();
    final service = CleanupFake(repo)..uid = 'usuario-a';
    service.pendingCleanup = Completer<void>();
    final exit = service.setUser(null);
    var completed = false;
    final login = service.setUser('usuario-b').then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    service.pendingCleanup!.complete();
    await exit;
    await login;
    expect(completed, isTrue);
    expect(service.uid, 'usuario-b');
    await repo.controller.close();
  });
  test('cambiar directamente de usuario inicia la limpieza anterior', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final repo = NotificationTasks();
    final service = CleanupFake(repo)..uid = 'usuario-a';
    await service.setUser('usuario-b');
    expect(service.calls, 1);
    expect(service.uid, 'usuario-b');
    await repo.controller.close();
  });
}
