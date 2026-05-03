import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app_navigator_key.dart';

class FirebaseApi {
  FirebaseApi._();

  /// Initialize notification permission (called from [main]).
  static Future<void> initNotification() async {
    await FirebaseMessaging.instance.requestPermission(
      sound: true,
      alert: true,
      badge: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token (init): $token');
  }

  static bool _listenersAttached = false;

  static void _handleMessage(RemoteMessage? message) {
    if (message == null) return;

    final title = message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    debugPrint('FCM message: $title');

    if (title == null && body == null) return;

    final nav = tasteTailorNavigatorKey.currentState;
    final ctx = nav?.context;
    if (ctx == null || !ctx.mounted) return;

    showDialog<void>(
      context: ctx,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title ?? 'Notification'),
          content: Text(body ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Single registration for FCM streams (global [tasteTailorNavigatorKey]).
  static void initPushNotifications() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground FCM: ${message.notification?.title}');
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Opened from FCM: ${message.notification?.title}');
      _handleMessage(message);
    });
  }
}
