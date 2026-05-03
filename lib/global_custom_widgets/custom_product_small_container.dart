import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProductDetailSmallContainer extends StatelessWidget {
  final String? title;
  final String? label;
  final VoidCallback? onTap;

  const CustomProductDetailSmallContainer({
    super.key,
    this.onTap,
     this.title,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Function to limit words in the title
    String limitWords(String text, int wordLimit) {
      List<String> words = text.split(RegExp(r'\s+'));
      return words.take(wordLimit).join(' ') + (words.length > wordLimit ? '...' : '');
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.006.h,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        //        height: MediaQuery.of(context).size.height * 0.038.h,
          height: MediaQuery.of(context).size.height * 0.06.h,
          width:  MediaQuery.of(context).size.width * 0.26.w,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration:  BoxDecoration(
            color: Colors.deepOrange.shade200,
             borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null)
                Text(
                  label!,
                  style:   TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize: 11.sp),
                ),
              const SizedBox(width: 2),
              if (title != null)// Provides spacing between label and title
              Text(
                limitWords(title!, 8),
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(color: Colors.black,fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
