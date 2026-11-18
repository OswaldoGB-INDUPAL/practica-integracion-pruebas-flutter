import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:practica_integracion_pruebas_flutter/data/notification_service.dart';
import 'package:practica_integracion_pruebas_flutter/data/repositories.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';
import 'package:practica_integracion_pruebas_flutter/models/task.dart';

class NotificationTasks implements TaskRepository {
  final controller = StreamController<List<Task>>.broadcast();
  int reads = 0;
  @override
  Stream<List<Task>> watchTasks() {
    reads++;
    return controller.stream;
  }

  @override
  Future<void> save(Task task) async {}
  @override
  Future<void> delete(String id) async {}
}

void main() {
  final task = Task(
    id: 't1',
    title: 'Comprar café',
    description: '',
    done: false,
    createdAt: DateTime.utc(2026),
  );
  testWidgets('FCM abre el detalle solicitado para el usuario actual', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final messenger = GlobalKey<ScaffoldMessengerState>();
    final repo = NotificationTasks();
    final service = NotificationService(navigator, messenger, (_) => repo)
      ..uid = 'u1';
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        scaffoldMessengerKey: messenger,
        onGenerateRoute: appRoute,
        home: const Scaffold(body: Text('Inicio')),
      ),
    );
    final opened = service.open(
      RemoteMessage(data: {'route': '/detalle', 'id': 't1'}),
    );
    repo.controller.add([task]);
    await opened;
    await tester.pumpAndSettle();
    expect(find.text('Comprar café'), findsOneWidget);
    expect(find.text('Detalle'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repo.controller.close();
  });
  testWidgets('FCM ignora una ruta no permitida', (tester) async {
    final repo = NotificationTasks();
    final service = NotificationService(
      GlobalKey<NavigatorState>(),
      GlobalKey<ScaffoldMessengerState>(),
      (_) => repo,
    )..uid = 'u1';
    await service.open(
      RemoteMessage(data: {'route': '/administracion', 'id': 't1'}),
    );
    expect(repo.reads, 0);
    await repo.controller.close();
  });
  testWidgets('FCM no abre detalle si la sesión cambia durante la lectura', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final messenger = GlobalKey<ScaffoldMessengerState>();
    final repo = NotificationTasks();
    final service = NotificationService(navigator, messenger, (_) => repo)
      ..uid = 'u1';
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        scaffoldMessengerKey: messenger,
        onGenerateRoute: appRoute,
        home: const Scaffold(body: Text('Inicio')),
      ),
    );
    final opened = service.open(
      RemoteMessage(data: {'route': '/detalle', 'id': 't1'}),
    );
    service.uid = null;
    repo.controller.add([task]);
    await opened;
    await tester.pumpAndSettle();
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Comprar café'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await repo.controller.close();
  });
}
