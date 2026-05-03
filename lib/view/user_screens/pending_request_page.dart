// import 'package:taste_tailor/model/request_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../global_custom_widgets/custom_product_small_container.dart';
// import '../../global_custom_widgets/custom_userinfo_section.dart';
// import '../drawer/user_drawer.dart';
//
// class PendingRequestScreen extends StatefulWidget {
//   const PendingRequestScreen({super.key});
//   static const String tag = "PendingRequestScreen";
//
//   @override
//   State<PendingRequestScreen> createState() => _PendingRequestScreenState();
// }
//
// class _PendingRequestScreenState extends State<PendingRequestScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final user = FirebaseAuth.instance.currentUser;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//           title: const Text('My Requests',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           centerTitle: true,
//           backgroundColor: Colors.deepOrange.shade200),
//       drawer: const UserDrawer(),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('food_orders')
//               .where('clientId', isEqualTo: user!.uid)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//               return ListView.builder(
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   // Parse Firestore data into RequestModel
//                   final request = RequestModel.fromJson(
//                     snapshot.data!.docs[index].data() as Map<String, dynamic>,
//                   );
//                   return buildRequestCard(context, request);
//                 },
//               );
//             } else {
//               return const Center(child: Text('No requests found.'));
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget buildRequestCard(BuildContext context, RequestModel request) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 UserInfoSection(image: ''),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomProductDetailSmallContainer(title: request.itemName),
//                     CustomProductDetailSmallContainer(
//                         title: request.totalPerson),
//                     CustomProductDetailSmallContainer(
//                         title: request.arrivalTime),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomProductDetailSmallContainer(title: request.fare),
//                     CustomProductDetailSmallContainer(title: request.date),
//                     CustomProductDetailSmallContainer(title: request.eventTime),
//                   ],
//                 )
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(
//                   vertical: MediaQuery.of(context).size.height * 0.006),
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.1,
//                 width: MediaQuery.of(context).size.width * 0.8,
//                 decoration: BoxDecoration(color: Colors.deepOrange.shade200),
//                 child: Center(
//                     child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(request.ingredients),
//                       ),
//                     ],
//                   ),
//                 )),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
