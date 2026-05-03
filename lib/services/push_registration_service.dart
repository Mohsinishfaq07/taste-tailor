import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Same topic ID as in `functions/index.js`.
const String kChefAlertsTopic = 'chef_alerts';

/// Saves FCM token to Firestore and subscribes chefs to broadcast topics.
///
/// Sending actual notifications requires deployed Cloud Functions (see `functions/`).
class PushRegistrationService {
  PushRegistrationService._();

  static final _firestore = FirebaseFirestore.instance;

  /// Call after Firebase Auth + verified `allusers` doc (splash, login, signup).
  static Future<void> syncForAuthenticatedUser({String? role}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final authOk = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!authOk) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    final r = (role ?? '').trim().toLowerCase();
    final isChef = r == 'chief';

    await _firestore.collection('allusers').doc(user.uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (isChef) {
      await FirebaseMessaging.instance.subscribeToTopic(kChefAlertsTopic);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(kChefAlertsTopic);
    }
  }

  static Future<void> onLogoutCleanup({required String? role}) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        await _firestore.collection('allusers').doc(user.uid).set({
          'fcmToken': FieldValue.delete(),
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      final r = (role ?? '').trim().toLowerCase();
      if (r == 'chief') {
        await FirebaseMessaging.instance.unsubscribeFromTopic(kChefAlertsTopic);
      }
    } catch (_) {
      /* best-effort */
    }
  }

  /// Register once near app startup (logged-in or anonymous — token skipped if denied).
  static void startTokenRefreshSync() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || token.isEmpty) return;
      try {
        final snap =
            await _firestore.collection('allusers').doc(user.uid).get();
        final role = snap.data()?['role']?.toString();
        await syncForAuthenticatedUser(role: role);
      } catch (_) {
        await _firestore.collection('allusers').doc(user.uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }
}
