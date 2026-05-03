// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class CustomProductDetailContainer extends StatefulWidget {
//   final String title;
//   final double? width ;
//   final String? label ;
//     const CustomProductDetailContainer({super.key, required this.title,
// this.label,
//   this.width= 150,
//   });
//
//   @override
//   State<CustomProductDetailContainer> createState() => _CustomProductDetailContainerState();
// }
//
// class _CustomProductDetailContainerState extends State<CustomProductDetailContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           vertical: MediaQuery.of(context).size.height * 0.006.h),
//       child: Container(
//
//           decoration:   BoxDecoration(color: Colors.pinkAccent.shade200),
//           child: Center(child: Padding(
//             padding:   EdgeInsets.all(8.0),
//             child: Flexible(child: Row(
//               children: [
//                 Text(widget.label!,),
//                 Text(widget.title),
//               ],
//             )),
//           ))),
//     );
//   }}