import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const CustomAuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange.shade900,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
          //  color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            maxLength: maxLength,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              counterText: "",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.deepOrange.shade300,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.deepOrange.shade300,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Colors.deepOrange.shade200,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
              ),
              errorMaxLines: 2,

              filled: true,
              fillColor: Colors.white,
              // contentPadding: EdgeInsets.symmetric(
              //   horizontal: 20.w,
              //   vertical: 16.h,
              // ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
