// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSmallTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefix;
  final IconData? sufix;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool isPasswordField;
  final VoidCallback? onPressed;

  const CustomSmallTextField({
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    required this.hintText,
    this.onPressed,
    this.prefix,
    this.sufix,
    this.isPasswordField = false,
    super.key,
  });

  @override
  _CustomSmallTextFieldState createState() => _CustomSmallTextFieldState();
}

class _CustomSmallTextFieldState extends State<CustomSmallTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText =
        widget.isPasswordField; // Initialize with true if it's a password field
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.056.h,
      width: MediaQuery.of(context).size.width * 0.7.w,
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red), // Change the color here
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          prefixIcon: widget.prefix,
          suffixIcon:
              IconButton(icon: Icon(widget.sufix), onPressed: widget.onPressed),
          isDense: true,
          contentPadding: EdgeInsets.all(10.h),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
