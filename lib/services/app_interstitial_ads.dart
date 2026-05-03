import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_config.dart';

/// Interstitial ads with light frequency limits. Preload after [MobileAds.initialize].
class AppInterstitialAds {
  AppInterstitialAds._();

  static InterstitialAd? _loaded;
  static bool _loading = false;
  static DateTime? _lastShownAt;
  static int _sessionImpressions = 0;

  static const int _maxPerSession = 4;
  static const Duration _minInterval = Duration(seconds: 90);

  static void preload() {
    if (_loaded != null || _loading) return;
    _loading = true;

    InterstitialAd.load(
      adUnitId: AdmobConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _loaded = ad;
          if (kDebugMode) {
            debugPrint('Interstitial loaded (${AdmobConfig.interstitialUnitId})');
          }
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _loaded = null;
          if (kDebugMode) {
            debugPrint('Interstitial failed to load: $error');
          }
        },
      ),
    );
  }

  static bool _allowedByCaps() {
    if (_sessionImpressions >= _maxPerSession) return false;
    if (_lastShownAt == null) return true;
    return DateTime.now().difference(_lastShownAt!) >= _minInterval;
  }

  /// Shows a loaded interstitial if policy caps allow; otherwise runs [then] immediately.
  /// Always invokes [then] exactly once (after the ad is dismissed or if no ad).
  static Future<void> showThen(VoidCallback then) async {
    if (!_allowedByCaps()) {
      then();
      preload();
      return;
    }

    final ad = _loaded;
    _loaded = null;

    if (ad == null) {
      then();
      preload();
      return;
    }

    void finish() {
      _lastShownAt = DateTime.now();
      _sessionImpressions++;
      preload();
      then();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd a) {
        a.dispose();
        finish();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd a, AdError error) {
        if (kDebugMode) {
          debugPrint('Interstitial failed to show: $error');
        }
        a.dispose();
        finish();
      },
    );

    ad.show();
  }
}
