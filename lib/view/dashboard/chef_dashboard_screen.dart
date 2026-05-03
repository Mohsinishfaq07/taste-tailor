import 'dart:async';

import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/global_custom_widgets/custom_small_buttons.dart';
import 'package:taste_tailor/global_custom_widgets/custom_text_form_field.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/model/client_detail_model.dart';
import 'package:taste_tailor/model/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../utils/order_date_expiry.dart';
import '../chat/chat_conversation_screen.dart';
import '../drawer/chef_drawer.dart';

class ChefDashboardScreen extends StatefulWidget {
  const ChefDashboardScreen({super.key});
  static const String tag = "ChefDashboardScreen";

  @override
  State<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends State<ChefDashboardScreen>
    with SingleTickerProviderStateMixin {
  final AppDatabase database = AppDatabase();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController fareController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  final Map<String, ClientDetailModel> _clientCache = {};
  StreamSubscription? _foodSub;
  StreamSubscription? _requestsSub;
  List<_ChefSourceDoc> _filteredDocs = [];
  bool _isLoadingOrders = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
    _subscribeToOrders();
  }

  @override
  void dispose() {
    _foodSub?.cancel();
    _requestsSub?.cancel();
    _controller.dispose();
    fareController.dispose();
    super.dispose();
  }

  void _subscribeToOrders() {
    final firestore = FirebaseFirestore.instance;
    List<_ChefSourceDoc> foodDocs = [];
    List<_ChefSourceDoc> requestDocs = [];

    Future<void> merge(
      List<_ChefSourceDoc> food,
      List<_ChefSourceDoc> requests,
    ) async {
      final all = [...food, ...requests];
      final filtered = all.where((entry) {
        final data = entry.doc.data() as Map<String, dynamic>;
        final chefResponses = (data['chefResponses'] as List<dynamic>?) ?? [];
        if (chefResponses.any((r) => r['userId'] == user!.uid)) {
          return false;
        }
        final preferred =
            (data['preferredChiefId'] ?? '').toString().trim();
        if (preferred.isNotEmpty && preferred != user!.uid) {
          return false;
        }
        return true;
      }).toList();

      final missingIds = filtered
          .map((e) => (e.doc.data() as Map<String, dynamic>)['clientId'] as String?)
          .whereType<String>()
          .where((id) => !_clientCache.containsKey(id))
          .toList();

      if (missingIds.isNotEmpty) {
        final clients = await Future.wait(
          missingIds.map((id) async {
            try {
              return await database.getClientById(docId: id);
            } catch (_) {
              return _fallbackClient(id);
            }
          }),
        );
        for (var i = 0; i < missingIds.length; i++) {
          _clientCache[missingIds[i]] = clients[i];
        }
      }

      if (mounted) {
        setState(() {
          _filteredDocs = filtered;
          _isLoadingOrders = false;
        });
      }
    }

    _foodSub =
        firestore.collection('food_orders').snapshots().listen((snap) {
      foodDocs = snap.docs.map((d) => _ChefSourceDoc('food_orders', d)).toList();
      merge(foodDocs, requestDocs);
    }, onError: (_) {
      // e.g. permission-denied after sign-out races; avoids zone uncaught errors
    });

    _requestsSub =
        firestore.collection('requests').snapshots().listen((snap) {
      requestDocs = snap.docs.map((d) => _ChefSourceDoc('requests', d)).toList();
      merge(foodDocs, requestDocs);
    }, onError: (_) {});
  }

  ClientDetailModel _fallbackClient(String clientId) {
    return ClientDetailModel(
      address: '',
      email: '',
      name: 'Client',
      number: '',
      password: '',
      userId: clientId,
      image: '',
      role: 'user',
      timestamp: Timestamp.now(),
    );
  }

  void _submitNewFare(String chefId, String newFare) async {
    if (!mounted) return;
    Fluttertoast.showToast(
        msg:
            context.tri((l) => l.priceUpdatedApproveRequest(newFare)));
  }

  void _showFareUpdateDialog(String documentId) {
    final ctx = context;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctx.tri((l) => l.submitNewPriceTitle),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildTextField(
                  controller: fareController,
                  hint: ctx.tri((l) => l.enterNewPriceHint),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton(
                      "Cancel",
                      () => Navigator.of(context).pop(),
                      isCancel: true,
                    ),
                    _buildDialogButton(
                      "Submit",
                      () {
                        if (fareController.text.isNotEmpty) {
                          Fluttertoast.showToast(
                            msg: ctx.tri((l) => l.priceUpdatedApproveRequest(
                                  fareController.text,
                                )),
                          );
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(
                              msg: ctx.tri((l) => l.pleaseEnterFare));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return false;
        }
        return _showExitDialog();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ChefDrawer(),
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Requests',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange.shade700,
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.deepOrange.shade700),
    );
  }

  Widget _buildBody() {
    if (_isLoadingOrders) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange.shade400,
        ),
      );
    }

    if (_filteredDocs.isEmpty) {
      return const Center(child: Text('No requests available.'));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: _filteredDocs.length,
      itemBuilder: (context, index) {
        final entry = _filteredDocs[index];
        final request = RequestModel.fromJson(
          entry.doc.data() as Map<String, dynamic>,
        );
        final client = _clientCache[request.clientId];

        if (client == null) return _buildLoadingCard();

        return _buildRequestCard(
          context,
          request,
          entry.doc.id,
          entry.source,
          client,
        );
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    RequestModel request,
    String documentId,
    String sourceCollection,
    ClientDetailModel client,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFFFB74D),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(context, client, request),
          _buildCardDetails(request),
          _buildIngredients(request.ingredients),
          _buildCardActions(request, documentId, sourceCollection),
        ],
      ),
    );
  }

  Widget _buildCardHeader(
    BuildContext context,
    ClientDetailModel client,
    RequestModel request,
  ) {
    final offerExpired = isOrderMessagingExpired(request);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE082),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.r),
          topRight: Radius.circular(14.r),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: const Color(0xFFFFE082),
            child: const Text('👤'),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name.isEmpty ? 'Client' : client.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D4037),
                  ),
                ),
                Text(
                  client.number.isEmpty ? '-' : client.number,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF8D6E63),
                  ),
                ),
                if (request.preferredChiefId.trim().isNotEmpty &&
                    request.preferredChiefId.trim() == user?.uid) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFF66BB6A)),
                    ),
                    child: Text(
                      '⭐ Client booked you for this',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: offerExpired
                ? 'Messaging disabled — offer expired'
                : 'Message client',
            onPressed: offerExpired
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(
                          peerUserId: client.userId,
                        ),
                      ),
                    );
                  },
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              color: offerExpired
                  ? Colors.brown.shade300
                  : Colors.deepOrange.shade900,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(RequestModel request) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 4.h),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: [
          _buildDetailRow('🍲', 'Food', request.itemName),
          _buildDetailRow('👥', 'People', request.totalPerson),
          _buildDetailRow('📅', 'Date', request.date),
          _buildDetailRow('⏰', 'Event', request.eventTime),
          _buildDetailRow('🕒', 'Arrival', request.arrivalTime),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1),
      ),
      child: Text(
        '$emoji $label: $value',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5D4037),
        ),
      ),
    );
  }

  Widget _buildIngredients(String ingredients) {
    return Container(
      margin: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 6.h),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD0F4DE),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🥕 Ingredients',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            ingredients,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF1B5E20)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(
    RequestModel request,
    String documentId,
    String sourceCollection,
  ) {
    final expired = isOpenOrderExpired(request);

    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 2.h, 10.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expired)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Icon(Icons.hourglass_disabled_rounded,
                      color: Colors.brown.shade700, size: 18.sp),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Event date has passed — chefs cannot accept this request.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              _buildActionButton(
                Icons.close,
                const Color(0xFFEF5350),
                () async {
                  final targetDocId = await _ensureOrderInFoodOrders(
                    sourceCollection: sourceCollection,
                    documentId: documentId,
                    request: request,
                  );
                  await database.rejectByChief(
                      docId: targetDocId, userId: user!.uid);
                },
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap:
                      expired ? null : () => _showFareUpdateDialog(documentId),
                  child: Opacity(
                    opacity: expired ? 0.55 : 1,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border:
                            Border.all(color: const Color(0xFFFFCC80), width: 1),
                      ),
                      child: Text(
                        '💸 Rs. ${request.fare}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6D4C41),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              if (!expired)
                _buildActionButton(
                  Icons.check,
                  const Color(0xFF66BB6A),
                  () async {
                    final targetDocId = await _ensureOrderInFoodOrders(
                      sourceCollection: sourceCollection,
                      documentId: documentId,
                      request: request,
                    );
                    await database.acceptByChief(
                      docId: targetDocId,
                      userId: user!.uid,
                      fare: fareController.text.isEmpty
                          ? request.fare
                          : fareController.text,
                    );
                  },
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                    border:
                        Border.all(color: Colors.brown.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'Expired',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown.shade900,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> _ensureOrderInFoodOrders({
    required String sourceCollection,
    required String documentId,
    required RequestModel request,
  }) async {
    if (sourceCollection == 'food_orders') return documentId;
    final foodRef =
        FirebaseFirestore.instance.collection('food_orders').doc(documentId);
    final foodSnap = await foodRef.get();
    if (!foodSnap.exists) {
      await foodRef.set(request.toJson());
    }
    await FirebaseFirestore.instance.collection('requests').doc(documentId).delete();
    return documentId;
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange.shade400,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onTap,
      {bool isCancel = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isCancel ? Colors.grey.shade200 : Colors.deepOrange.shade400,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isCancel ? Colors.black87 : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exit App',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Do you really want to exit the app?',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    "No",
                    () => Navigator.of(context).pop(false),
                    isCancel: true,
                  ),
                  _buildDialogButton(
                    "Yes",
                    () {
                      Navigator.of(context).pop(true);
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return shouldPop ?? false;
  }
}

class _ChefSourceDoc {
  final String source;
  final QueryDocumentSnapshot doc;
  _ChefSourceDoc(this.source, this.doc);
}
