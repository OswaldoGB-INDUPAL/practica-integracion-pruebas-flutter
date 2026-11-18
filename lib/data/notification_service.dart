import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../data/repositories.dart';
import '../main.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService(this.navigatorKey, this.scaffoldKey, this.tasks);
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final TaskRepository Function(String) tasks;
  final List<StreamSubscription<dynamic>> subscriptions = [];
  String? uid;
  RemoteMessage? pending;

  Future<void> start() async {
    await FirebaseMessaging.instance.requestPermission();
    subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message.notification?.title ?? 'Nueva notificación'),
          ),
        );
      }),
    );
    subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(open));
    subscriptions.add(
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (uid != null) saveToken(uid!, token);
      }),
    );
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) open(initial);
  }

  Future<void> setUser(String? value) async {
    uid = value;
    if (value == null) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && uid == value) await saveToken(value, token);
    } catch (_) {
      debugPrint('No se pudo obtener el token de notificaciones.');
    }
    if (pending != null && uid == value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (uid != value || pending == null) return;
        final message = pending!;
        pending = null;
        open(message);
      });
    }
  }

  Future<void> saveToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      if (kDebugMode) debugPrint('Token FCM: $token');
    } catch (_) {
      debugPrint('No se pudo guardar el token de notificaciones.');
    }
  }

  Future<void> open(RemoteMessage message) async {
    if (message.data['route'] != '/detalle' || message.data['id'] is! String) {
      return;
    }
    final user = uid;
    if (user == null || navigatorKey.currentState == null) {
      pending = message;
      return;
    }
    try {
      final repo = tasks(user);
      final list = await repo.watchTasks().first;
      final matches = list.where((task) => task.id == message.data['id']);
      if (matches.isEmpty || uid != user) return;
      navigatorKey.currentState?.pushNamed(
        '/detalle',
        arguments: TaskRouteArguments(repo, matches.first),
      );
    } catch (_) {
      scaffoldKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la tarea de la notificación.'),
        ),
      );
    }
  }

  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  }
}
