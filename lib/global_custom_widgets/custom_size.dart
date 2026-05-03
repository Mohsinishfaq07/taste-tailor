import 'package:flutter/material.dart';

class CustomSize extends StatelessWidget {
  final double? height;
  final double? width;

  const CustomSize({this.height, this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
    );
  }
}
