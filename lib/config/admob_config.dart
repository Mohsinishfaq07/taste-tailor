import 'package:flutter/foundation.dart';

/// Bawarchi App (AdMob console). Use release IDs only in non-debug builds so
/// impressions during development do not count as invalid traffic.
class AdmobConfig {
  AdmobConfig._();

  /// Application ID (already in AndroidManifest & iOS Info.plist).
  static const String androidIosAppId =
      'ca-app-pub-1722510192187285~1339402946';

  /// Production interstitial unit.
  static const String interstitialReleaseUnitId =
      'ca-app-pub-1722510192187285/3667106821';

  /// Google sample interstitial — use in [kDebugMode] only.
  static const String interstitialTestUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get interstitialUnitId =>
      kDebugMode ? interstitialTestUnitId : interstitialReleaseUnitId;
}
