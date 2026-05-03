import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:taste_tailor/l10n/app_localizations.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import 'package:taste_tailor/utils/tri_localization.dart';

extension ContextTriLocalization on BuildContext {
  /// English, Urdu, or **English (Urdu)** in hybrid mode; rebuilds on language change.
  String tri(String Function(AppLocalizations l) fn) {
    final notifier = watch<LocaleNotifier>();
    return TriLocalization.tri(notifier, fn);
  }
}
