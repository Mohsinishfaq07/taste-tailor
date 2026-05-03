import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHorizontalDivider extends StatelessWidget {
  const CustomHorizontalDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: MediaQuery.of(context).size.width * 0.116.w,
      endIndent: MediaQuery.of(context).size.width * 0.116.w,
      color: Colors.black,
    );
  }
}
