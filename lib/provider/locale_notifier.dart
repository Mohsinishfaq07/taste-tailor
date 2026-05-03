import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLocalePref = 'app_language_code';

enum AppLanguageMode {
  english,
  urdu,
  hybrid,
}

/// App-wide language mode; use [toast] where [BuildContext] is unavailable.
class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier() {
    _scopedInstance ??= this;
    _bootstrap();
  }

  static LocaleNotifier? _scopedInstance;

  /// Last constructed notifier — matches the single Provider in [main].
  static LocaleNotifier? get scoped => _scopedInstance;

  AppLanguageMode _mode = AppLanguageMode.english;
  AppLanguageMode get mode => _mode;

  /// For [MaterialApp.locale]. Hybrid uses English delegate + LTR; Urdu uses RTL.
  Locale get locale => _mode == AppLanguageMode.urdu
      ? const Locale('ur')
      : const Locale('en');

  bool get isUrdu => _mode == AppLanguageMode.urdu;
  bool get isHybrid => _mode == AppLanguageMode.hybrid;

  static AppLanguageMode _parseMode(String raw) {
    final c = raw.toLowerCase().trim();
    if (c == 'ur') return AppLanguageMode.urdu;
    if (c == 'hy' || c == 'hybrid') return AppLanguageMode.hybrid;
    return AppLanguageMode.english;
  }

  String _modeToPref(AppLanguageMode m) {
    switch (m) {
      case AppLanguageMode.english:
        return 'en';
      case AppLanguageMode.urdu:
        return 'ur';
      case AppLanguageMode.hybrid:
        return 'hy';
    }
  }

  Future<void> _bootstrap() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kLocalePref) ?? 'en';
      _mode = _parseMode(raw);
    } finally {
      notifyListeners();
    }
  }

  /// `en`, `ur`, or `hy` (hybrid: English with Urdu in parentheses).
  Future<void> setLanguageCode(String code) async {
    _mode = _parseMode(code);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLocalePref, _modeToPref(_mode));
    notifyListeners();
  }

  /// Strings used from services / Firebase without widget context.
  static String toast(String english, String urdu) {
    final s = scoped;
    if (s == null) return english;
    if (s.isUrdu) return urdu;
    if (s.isHybrid) {
      if (urdu.isEmpty || english == urdu) return english;
      return '$english ($urdu)';
    }
    return english;
  }
}
