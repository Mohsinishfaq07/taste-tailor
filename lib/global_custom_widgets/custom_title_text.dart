import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTitleText extends StatelessWidget {
  final String text;
  final double topPaddingFactor;
  final double bottomPaddingFactor;
  final FontWeight fontWeight;
  final Color color;

  const CustomTitleText({
    super.key,
    required this.text,
    this.topPaddingFactor = 0.03,
    this.bottomPaddingFactor = 0.07,
    this.fontWeight = FontWeight.w800,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * topPaddingFactor.h,
        bottom: MediaQuery.of(context).size.height * bottomPaddingFactor.h,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: fontWeight,
          color: color,
          fontSize: 28.sp,
        ),
      ),
    );
  }
}
