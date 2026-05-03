import 'package:taste_tailor/view/chef_screens/chef_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../model/app_database.dart';
import '../../model/request_model.dart'; // Import the RequestModel
import '../../provider/chief_dashboard_provider.dart';
import '../drawer/user_drawer.dart';
import 'package:taste_tailor/utils/order_date_expiry.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/utils/unfocus_on_route_cover_mixin.dart';

class UserMyOrdersScreen extends StatefulWidget {
  const UserMyOrdersScreen({super.key});
  static const String tag = "MyOrderScreen";

  @override
  State<UserMyOrdersScreen> createState() => _UserMyOrdersScreenState();
}

class _UserMyOrdersScreenState extends State<UserMyOrdersScreen>
    with UnfocusOnRouteCoverMixin {
  AppDatabase database = AppDatabase();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot<Object?>> _filterByItemName(
    List<QueryDocumentSnapshot<Object?>> docs,
  ) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return docs;
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;
      final name = (data['itemName'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFFA726), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4E342E),
          ),
          decoration: InputDecoration(
            hintText: '🔍 Search order by dish name',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF8D6E63),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon:
                Icon(Icons.search_rounded, color: Colors.deepOrange.shade400),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.deepOrange.shade400,
                      size: 22,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('My Orders',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      drawer: const UserDrawer(),
      body: currentUser == null
          ? const Center(child: Text('Please login again.'))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Consumer<RequestData>(
                builder: (context, requestData, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSearchBar(),
                      Expanded(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('food_orders')
                              .where('clientId', isEqualTo: currentUser.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text("No active orders."));
                              }

                              final filteredDocs =
                                  snapshot.data!.docs.where((doc) {
                                final chefResponses =
                                    (doc['chefResponses'] as List<dynamic>?) ??
                                        [];
                                final acceptedChiefId =
                                    doc['acceptedChiefId'] as String? ?? '';

                                return chefResponses.any((response) =>
                                    acceptedChiefId == 'noChiefSelected');
                              }).toList();

                              if (filteredDocs.isEmpty) {
                                return const Center(
                                  child: Text("No active orders."),
                                );
                              }

                              final searchDocs =
                                  _filterByItemName(filteredDocs);
                              if (searchDocs.isEmpty) {
                                return const Center(
                                  child: Text(
                                      'No orders match your search.'),
                                );
                              }

                              return ListView.builder(
                    itemCount: searchDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final request = RequestModel.fromJson(
                        searchDocs[index].data() as Map<String, dynamic>,
                      );
                      final orderExpired = isOpenOrderExpired(request);
                      String docId = searchDocs[index].id;
                      // final timestamp = request.timestamp; // Use the timestamp from RequestModel
                      // final dateTime = timestamp.toDate();
                      // final year = dateTime.year;
                      // final month = dateTime.month;
                      // final day = dateTime.day;
                      // final hour = dateTime.hour;
                      // final minute = dateTime.minute;

                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      UserInfoSection(image: ''),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.011.h,
                                      ),
                                      SizedBox(
                                        height: 22.h,
                                      ),
                                      CustomProductDetailSmallContainer(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChefDetailsScreen(
                                                      userid: request
                                                          .acceptedChiefId), // Use acceptedChiefId from RequestModel
                                            ),
                                          );
                                        },
                                        label: "Chef Details",
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomProductDetailSmallContainer(
                                          label: "Item",
                                          title: request
                                              .itemName), // Use itemName from RequestModel
                                      CustomProductDetailSmallContainer(
                                          label: "People",
                                          title: request
                                              .totalPerson), // Use totalPerson from RequestModel
                                      CustomProductDetailSmallContainer(
                                          label: "Time",
                                          title: request
                                              .arrivalTime), // Use arrivalTime from RequestModel
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomProductDetailSmallContainer(
                                        label: context.tri((l) => l.fareLabel),
                                        title: request
                                            .fare, // Use fare from RequestModel
                                      ),
                                      CustomProductDetailSmallContainer(
                                        label: "Date",
                                        title: request
                                            .date, // Use date from RequestModel
                                      ),
                                      CustomProductDetailSmallContainer(
                                        label: "Time",
                                        title: request
                                            .eventTime, // Use eventTime from RequestModel
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
                                    width: MediaQuery.of(context).size.width *
                                        0.86.w,
                                    decoration: BoxDecoration(
                                        color: Colors.deepOrange.shade200),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Available Ingredients",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(request
                                                .ingredients), // Use ingredients from RequestModel
                                          ],
                                        ),
                                      )),
                                    )),
                              ),
                              if (orderExpired)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10.h),
                                  child: Text(
                                    'This order has expired — you cannot approve a chef.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.sp,
                                      color: Colors.brown.shade800,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      color: Colors.deepOrange.shade200,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.black),
                                        onPressed: () async {
                                          database.rejectByClient(
                                              docId: docId,
                                              chiefId:
                                                  request.chefResponses[index]
                                                      ['userId']);
                                        },
                                      ),
                                    ),
                                    Container(
                                      color: Colors.deepOrange.shade200,
                                      child: IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.black),
                                        onPressed: () async {
                                          database.acceptedByClient(
                                              docId: docId,
                                              chiefId:
                                                  request.chefResponses[index]
                                                      ['userId']);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       top: 8, left: 5, right: 5),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
