// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;

  final String? hintText;
  final String? label;
  final Widget? prefix;
  final IconData? suffix;
  final VoidCallback? onPressedSuffix;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool isPasswordField;
  final bool formatDate;
  final bool formatTime;
  final bool readOnly;
  final int? maxLength;
  final double? width;
  final double? height;

  const CustomTextField({
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.label,
    this.prefix,
    this.suffix,
    this.onPressedSuffix,
    this.isPasswordField = false,
    this.formatDate = false,
    this.formatTime = false,
    this.readOnly = false,
    this.maxLength,
    this.width,
    this.height,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPasswordField;
    if (widget.keyboardType == TextInputType.phone) {
      widget.controller.text = '03'; // Initialize with '03'
      widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    double defaultWidth =
        widget.width ?? MediaQuery.of(context).size.width * 0.8;
    double defaultHeight = widget.height ?? 70;

    return SizedBox(
      width: defaultWidth,
      height: defaultHeight,
      child: TextFormField(
          readOnly: widget.readOnly,
          textAlign: TextAlign.start,
          maxLength: widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            label: widget.label != null ? Text(widget.label!) : null,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            // hintText: widget.hintText,
            // hintStyle: TextStyle(color: Colors.transparent, fontSize: 14.sp),
             labelStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
            prefixIcon: widget.prefix,
            suffixIcon: _buildSuffixIcon(),
            contentPadding: EdgeInsets.symmetric(
                vertical: defaultHeight * 0.1, horizontal: 20.w),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9.h),
              borderSide: const BorderSide(
                color: Colors.black, // Adjust the border color as needed
                width: 1.0, // Adjust the border width as needed
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9.h),
              borderSide: const BorderSide(
                color:
                    Colors.transparent, // Adjust the color for the normal state
                width: 1.0, // Adjust the width as needed
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9.h),
              borderSide: const BorderSide(
                color: Colors
                    .transparent, // Adjust the color for the focused state
                width: 1.0, // Adjust the width as needed
              ),
            ),
            counterText: '',
          ),

          inputFormatters: widget.formatDate
              ? [DateInputFormatter()]
              : widget.formatTime
                  ? [TimeInputFormatter()]
                  : [
                      if (widget.keyboardType == TextInputType.phone)
                        _PhoneNumberInputFormatter()
                    ],
          validator: widget.formatDate ? _validateDate : null,

    )
    );
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a date';

    try {
      // Using RegExp to check for a basic date format (dd/mm/yyyy)
      if (!RegExp(r'\d{2}/\d{2}/\d{4}').hasMatch(value)) {
        return 'Invalid date format. Use DD/MM/YYYY';
      }

      // Parsing the date from DD/MM/YYYY format
      List<String> parts = value.split('/');
      DateTime inputDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      if (inputDate.isBefore(DateTime.now())) {
        return 'Please enter a current or future date';
      }
    } catch (e) {
      // This catches any parsing errors
      return 'Invalid date format or incorrect date';
    }

    return null;
  }
  Widget? _buildSuffixIcon() {
    if (widget.isPasswordField) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffix != null && widget.onPressedSuffix != null) {
      return IconButton(
        icon: Icon(widget.suffix),
        onPressed: widget.onPressedSuffix,
      );
    }
    return null;
  }

}

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericOnly.length > 4) {
      return oldValue; // If more than 4 digits, revert to old value
    }

    StringBuffer buffer = StringBuffer();
    if (numericOnly.isNotEmpty) {
      if (numericOnly.length > 2) {
        // Parse the hour and ensure it doesn't exceed 12
        int hours = int.parse(numericOnly.substring(0, 2)).clamp(0, 12);
        buffer.write(
            hours.toString().padLeft(2, '0')); // Pad only if hours are complete
        buffer.write(':'); // Add colon after the hour
        if (numericOnly.length > 2) {
          // Parse the minute and ensure it doesn't exceed 59
          int minutes = int.parse(numericOnly.substring(2, numericOnly.length))
              .clamp(0, 59);
          buffer.write(minutes
              .toString()
              .padLeft(2, '0')); // Pad only if minutes are complete
        }
      } else {
        // Allow user to freely type the hour digits
        buffer.write(numericOnly.substring(0, numericOnly.length));
      }
    }

    String formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      // Adjust the cursor position accordingly
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Extracting only the digits from the input
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    // Ensure we do not exceed the length for dd/mm/yyyy format (i.e., 8 digits + 2 slashes = 10 characters)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Formatting the digits with slashes
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      // Insert slashes after the day (2 digits) and month (4 digits) parts
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }

    // Returning the newly formatted value, adjusting the cursor position accordingly
    return newValue.copyWith(
      text: formatted,
      // Ensure the cursor is positioned correctly, at the end of the current input
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Ensure the input always starts with '03'
    if (!newValue.text.startsWith('03')) {
      return const TextEditingValue(
          text: '03', selection: TextSelection.collapsed(offset: 2));
    }
    // Limit to 11 characters total
    if (newValue.text.length > 11) {
      return TextEditingValue(
        text: newValue.text.substring(0, 11),
        selection: const TextSelection.collapsed(offset: 11),
      );
    }
    return newValue;
  }
}
