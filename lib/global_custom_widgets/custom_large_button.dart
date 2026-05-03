import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLargeButton extends StatelessWidget {
  final VoidCallback ontap;
  final String title;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double? fontSize;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const CustomLargeButton({
    super.key,
    required this.title,
    required this.ontap,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.w600,
    this.fontSize,
    this.borderRadius = 30,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final deco = BoxDecoration(
      color: gradient == null && backgroundColor != null
          ? backgroundColor
          : null,
      gradient: gradient ??
          (backgroundColor == null
              ? LinearGradient(
                  colors: [
                    Colors.deepOrange.shade200,
                    Colors.deepOrange.shade300,
                    Colors.deepOrange.shade400,
                    Colors.deepOrange.shade500,
                    Colors.deepOrange.shade600,
                    Colors.deepOrange.shade700,
                    Colors.deepOrange.shade800,
                    Colors.deepOrange.shade900,
                  ],
                )
              : null),
      border: Border.all(color: backgroundColor ?? Colors.white),
      borderRadius: BorderRadius.circular(borderRadius.r),
      boxShadow: boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 5),
            ),
          ],
    );

    final textWidget = Text(
      title,
      textAlign: TextAlign.center,
      softWrap: true,
      maxLines: 1,
      style: TextStyle(
        fontWeight: fontWeight,
        color: textColor,
        fontSize: fontSize ?? 13.sp,
        height: 1.28,
      ),
    );

    return InkWell(
      onTap: ontap,
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: Container(
        width: width ?? 0.82.sw,
        height: height,
        constraints: height == null
            ? BoxConstraints(minHeight: 52.h)
            : null,
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: height != null ? 8.h : 14.h,
        ),
        decoration: deco,
        alignment: Alignment.center,
        child: textWidget,
      ),
    );
  }
}
