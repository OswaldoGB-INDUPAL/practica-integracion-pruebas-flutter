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

Future<void> removeTokenIfMatching(
  FirebaseFirestore firestore,
  String uid,
  String token,
) async {
  final ref = firestore.collection('users').doc(uid);
  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(ref);
    if (snapshot.data()?['fcmToken'] == token) {
      transaction.update(ref, {'fcmToken': FieldValue.delete()});
    }
  });
}

class NotificationService {
  NotificationService(this.navigatorKey, this.scaffoldKey, this.tasks);
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final TaskRepository Function(String) tasks;
  final List<StreamSubscription<dynamic>> subscriptions = [];
  String? uid;
  RemoteMessage? pending;
  String? _lastToken;
  final Set<Future<void>> _writes = {};
  Future<void>? _cleanup;

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
    if (value == null) {
      if (uid != null) {
        final cleanup = prepareSignOut();
        _cleanup = cleanup;
        try {
          await cleanup;
        } finally {
          if (identical(_cleanup, cleanup)) _cleanup = null;
        }
      }
      return;
    }
    if (uid != null && uid != value) _cleanup = prepareSignOut();
    uid = value;
    final cleanup = _cleanup;
    if (cleanup != null) {
      try {
        await cleanup;
      } finally {
        if (identical(_cleanup, cleanup)) _cleanup = null;
      }
    }
    if (uid != value) return;
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      if (uid != value) return;
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
    if (uid != userId) return;
    _lastToken = token;
    final write = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'fcmToken': token}, SetOptions(merge: true));
    _writes.add(write);
    try {
      await write;
      if (kDebugMode) debugPrint('Token FCM: $token');
    } catch (_) {
      debugPrint('No se pudo guardar el token de notificaciones.');
    } finally {
      _writes.remove(write);
    }
  }

  Future<void> prepareSignOut() {
    final existing = _cleanup;
    if (existing != null) return existing;
    final cleanup = _performSignOutCleanup();
    _cleanup = cleanup;
    cleanup.whenComplete(() {
      if (identical(_cleanup, cleanup)) _cleanup = null;
    });
    return cleanup;
  }

  Future<void> _performSignOutCleanup() async {
    final previousUid = uid;
    final token = _lastToken;
    uid = null;
    pending = null;
    try {
      await Future.wait(_writes.toList()).timeout(const Duration(seconds: 2));
    } catch (_) {
      debugPrint('Hay escrituras de token pendientes.');
    }
    try {
      await FirebaseMessaging.instance
          .setAutoInitEnabled(false)
          .timeout(const Duration(seconds: 1));
      if (previousUid != null && token != null) {
        await removeTokenIfMatching(
          FirebaseFirestore.instance,
          previousUid,
          token,
        ).timeout(const Duration(seconds: 2));
      }
    } catch (_) {
      debugPrint('No se pudo quitar el token guardado.');
    }
    try {
      await FirebaseMessaging.instance.deleteToken().timeout(
        const Duration(seconds: 1),
      );
    } catch (_) {
      debugPrint('No se pudo revocar el token del dispositivo.');
    }
    _lastToken = null;
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
