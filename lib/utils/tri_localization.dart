import 'package:taste_tailor/l10n/app_localizations.dart';
import 'package:taste_tailor/l10n/app_localizations_en.dart';
import 'package:taste_tailor/l10n/app_localizations_ur.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';

/// Combines EN / UR / hybrid `English (اردو)` using the same getters as codegen.
class TriLocalization {
  TriLocalization._();

  static String tri(
    LocaleNotifier notifier,
    String Function(AppLocalizations l) fn,
  ) {
    final en = AppLocalizationsEn();
    final ur = AppLocalizationsUr();
    switch (notifier.mode) {
      case AppLanguageMode.english:
        return fn(en);
      case AppLanguageMode.urdu:
        return fn(ur);
      case AppLanguageMode.hybrid:
        final english = fn(en);
        final urdu = fn(ur);
        if (urdu.isEmpty || english == urdu) return english;
        return '$english ($urdu)';
    }
  }

  /// Prefer when there is no [BuildContext], e.g. after async gaps — uses [LocaleNotifier.scoped].
  static String triScoped(String Function(AppLocalizations l) fn) {
    final scoped = LocaleNotifier.scoped;
    if (scoped == null) return fn(AppLocalizationsEn());
    return tri(scoped, fn);
  }

  /// For validators / dialogs where you already have `read<LocaleNotifier>(listen: false)`.
  static String triSilent(
    LocaleNotifier notifier,
    String Function(AppLocalizations l) fn,
  ) {
    return tri(notifier, fn);
  }
}
