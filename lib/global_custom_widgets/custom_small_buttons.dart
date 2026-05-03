import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSmallButton extends StatelessWidget {
  final VoidCallback ontap;
  final String title;

  const CustomSmallButton({
    super.key,
    required this.title,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10.r),
        ),
        height: MediaQuery.of(context).size.height * 0.04.h,
        width: MediaQuery.of(context).size.width * 0.18.w,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
                fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}
