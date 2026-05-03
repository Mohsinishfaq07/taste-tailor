import 'package:flutter/material.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/l10n/app_localizations_en.dart';
import 'package:taste_tailor/l10n/app_localizations_ur.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/locale_notifier.dart';

/// English / اُردُو / hybrid (English with Urdu in parentheses).
class LanguageToggleBar extends StatelessWidget {
  const LanguageToggleBar({
    super.key,
    this.compact = false,
    this.margin,
  });

  final bool compact;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<LocaleNotifier>();
    final heading = context.tri((l) => l.languageHeading);
    final en = AppLocalizationsEn();

    return Padding(
      padding:
          margin ?? EdgeInsets.symmetric(horizontal: compact ? 0 : 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: compact ? 11.sp : 12.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5D4037),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? 5.h : 7.h),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              ChoiceChip(
                label: Text(
                  en.languageEnglish,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 10.sp : 11.5.sp,
                  ),
                ),
                selected: notifier.mode == AppLanguageMode.english,
                onSelected: (_) => notifier.setLanguageCode('en'),
                selectedColor: Colors.white.withValues(alpha: 0.92),
              ),
              ChoiceChip(
                label: Text(
                  'اردو',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 10.sp : 11.5.sp,
                  ),
                ),
                selected: notifier.mode == AppLanguageMode.urdu,
                onSelected: (_) => notifier.setLanguageCode('ur'),
                selectedColor: Colors.white.withValues(alpha: 0.92),
              ),
              ChoiceChip(
                label: Text(
                  notifier.isUrdu
                      ? AppLocalizationsUr().languageHybridChip
                      : en.languageHybridChip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 10.sp : 11.5.sp,
                  ),
                ),
                selected: notifier.mode == AppLanguageMode.hybrid,
                onSelected: (_) => notifier.setLanguageCode('hy'),
                selectedColor: Colors.white.withValues(alpha: 0.92),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
