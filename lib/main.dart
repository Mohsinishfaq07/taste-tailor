import 'package:taste_tailor/firebase_options.dart';
import 'package:taste_tailor/firebase_services.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import 'package:taste_tailor/services/push_registration_service.dart';
import 'package:taste_tailor/provider/chief_dashboard_provider.dart';
import 'package:taste_tailor/provider/chief_orders_provider.dart';
import 'package:taste_tailor/provider/user_myorders_provider.dart';
import 'package:taste_tailor/provider/user_myrequest_provider.dart';
import 'package:taste_tailor/provider/user_requestqueue_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'my_app.dart';
import 'services/app_interstitial_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();

  // App Check is not initialized here—you can skip enabling the App Check API
  // until you enable it in GCP + Firebase Console, then add `firebase_app_check`
  // back and call `FirebaseAppCheck.instance.activate(...)`.
  await FirebaseApi.initNotification();
  PushRegistrationService.startTokenRefreshSync();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ChangeNotifierProvider(create: (_) => RequestData()),
        ChangeNotifierProvider(create: (_) => MyOrders()),
        ChangeNotifierProvider(create: (_) => UserRequestQueueProvider()),
        ChangeNotifierProvider(create: (_) => UserMyRequsets()),
        ChangeNotifierProvider(create: (_) => UserMyOrders()),
        // ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseApi.initPushNotifications();
    AppInterstitialAds.preload();
  });
}
