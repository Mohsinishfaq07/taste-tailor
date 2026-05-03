import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../model/app_database.dart';
import '../../model/request_model.dart'; // Import your RequestModel
import '../../provider/chief_dashboard_provider.dart';
import '../drawer/chef_drawer.dart';

// ignore: must_be_immutable
class ChiefRequestQueueScreen extends StatelessWidget {
  static const String tag = "ChiefRequestScreen";

  ChiefRequestQueueScreen({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppDatabase database = AppDatabase();

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ChefDrawer(),
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Waiting for response',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Consumer<RequestData>(
          builder: (context, requestData, _) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('food_orders') // Use the correct collection name
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final chefResponses =
                        (doc['chefResponses'] as List<dynamic>?) ?? [];
                    final acceptedChiefId =
                        doc['acceptedChiefId'] as String? ?? '';
                    final preferred =
                        (doc['preferredChiefId'] ?? '').toString().trim();

                    final appliedHere = chefResponses.any((response) =>
                        response['userId'] == user!.uid &&
                        response['reqStatus'] == 'applied' &&
                        acceptedChiefId == 'noChiefSelected');
                    if (!appliedHere) return false;
                    if (preferred.isNotEmpty && preferred != user!.uid) {
                      return false;
                    }
                    return true;
                  }).toList();

                  // Parse Firestore data into RequestModel and filter

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final request = RequestModel.fromJson(
                        filteredDocs[index].data() as Map<String, dynamic>,
                      );

                      //   final timestamp = request.timestamp; // Assuming you have a timestamp field
                      //   final dateTime = timestamp.toDate();
                      // final year = dateTime.year;
                      // final month = dateTime.month;
                      // final day = dateTime.day;
                      // final hour = dateTime.hour;
                      // final minute = dateTime.minute;

                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      UserInfoSection(image: ''),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomProductDetailSmallContainer(
                                          label: "Item",
                                          title: request.itemName),
                                      CustomProductDetailSmallContainer(
                                          label: "People",
                                          title: request.totalPerson),
                                      CustomProductDetailSmallContainer(
                                          label: "Arrival:",
                                          title: request.arrivalTime),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child:
                                            CustomProductDetailSmallContainer(
                                          label:
                                              '${context.tri((l) => l.fareLabel)}:',
                                          title: request.chefResponses[index]
                                                  ['fare']
                                              .toString(),
                                        ),
                                      ),
                                      CustomProductDetailSmallContainer(
                                        label: "Date:",
                                        title: request.date,
                                      ),
                                      CustomProductDetailSmallContainer(
                                        label: "Event:",
                                        title: request.eventTime,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.006),
                                child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                        color: Colors.deepOrange.shade200),
                                    child: Center(
                                        child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Available Ingredients",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(request.ingredients),
                                        ],
                                      ),
                                    ))),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       top: 8, left: 5, right: 5),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text('Date: $day/$month/$year'),
                              //       Text('Time: $hour:$minute')
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.pink.shade200,
                  )); // Or any other loading indicator
                }
              },
            );
          },
        ),
      ),
    );
  }
}
