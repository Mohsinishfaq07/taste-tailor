import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/model/request_model.dart';
import 'package:taste_tailor/view/drawer/chef_drawer.dart';
import 'package:taste_tailor/view/user_screens/user_details_screen.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/utils/unfocus_on_route_cover_mixin.dart';

enum ChefOrderStatus { pending, active, completed }

class ChefMyOrderScreen extends StatefulWidget {
  const ChefMyOrderScreen({super.key});
  static const String tag = "ChefMyOrderScreen";

  @override
  State<ChefMyOrderScreen> createState() => _ChefMyOrderScreenState();
}

class _ChefMyOrderScreenState extends State<ChefMyOrderScreen>
    with UnfocusOnRouteCoverMixin {
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

  List<QueryDocumentSnapshot> _chefOrderDocs({
    required List<QueryDocumentSnapshot> docs,
    required String chefUid,
  }) {
    final filtered = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final chefResponses = (data['chefResponses'] as List<dynamic>?) ?? [];
      final acceptedChiefId = (data['acceptedChiefId'] ?? '').toString();
      final orderStatus = (data['orderStatus'] ?? '').toString();

      final isPendingForChef = chefResponses.any((response) =>
          response is Map &&
          response['userId'] == chefUid &&
          response['reqStatus'] == 'applied' &&
          acceptedChiefId == 'noChiefSelected');

      final isActiveForChef =
          acceptedChiefId == chefUid && orderStatus == 'assigned';
      final isCompletedForChef =
          acceptedChiefId == chefUid && orderStatus == 'completed';

      return isPendingForChef || isActiveForChef || isCompletedForChef;
    }).toList()
      ..sort((a, b) {
        final ta = (a.data() as Map<String, dynamic>)['timestamp'];
        final tb = (b.data() as Map<String, dynamic>)['timestamp'];
        if (ta is Timestamp && tb is Timestamp) {
          return tb.compareTo(ta);
        }
        return 0;
      });
    return filtered;
  }

  List<QueryDocumentSnapshot> _filterOrdersByName(
    List<QueryDocumentSnapshot> docs,
  ) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return docs;
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final itemName = (data['itemName'] ?? '').toString().toLowerCase();
      return itemName.contains(q);
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
    final user = FirebaseAuth.instance.currentUser;
    final database = AppDatabase();

    return Scaffold(
      drawer: const ChefDrawer(),
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      body: user == null
          ? const Center(child: Text('Please login again.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchBar(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('food_orders')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepOrange.shade200,
                          ),
                        );
                      }

                      final chefDocs = _chefOrderDocs(
                        docs: snapshot.data!.docs,
                        chefUid: user.uid,
                      );

                      if (chefDocs.isEmpty) {
                        return const Center(child: Text('No chef orders yet.'));
                      }

                      final filtered = _filterOrdersByName(chefDocs);
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No orders match your search.'),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(12.w),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final doc = filtered[index];
                          final request = RequestModel.fromJson(
                            doc.data() as Map<String, dynamic>,
                          );
                          final docId = doc.id;
                          final status = _getStatus(request, user.uid);
                          return _buildOrderCard(
                            context: context,
                            request: request,
                            docId: docId,
                            status: status,
                            database: database,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  ChefOrderStatus _getStatus(RequestModel request, String chefUid) {
    if (request.acceptedChiefId == chefUid && request.orderStatus == 'completed') {
      return ChefOrderStatus.completed;
    }
    if (request.acceptedChiefId == chefUid && request.orderStatus == 'assigned') {
      return ChefOrderStatus.active;
    }
    return ChefOrderStatus.pending;
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required RequestModel request,
    required String docId,
    required ChefOrderStatus status,
    required AppDatabase database,
  }) {
    if (status == ChefOrderStatus.active || status == ChefOrderStatus.completed) {
      return _buildAcceptedOrderCard(
        context: context,
        request: request,
        docId: docId,
        status: status,
        database: database,
      );
    }

    final statusMeta = _statusMeta(status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
            color: Colors.deepOrange.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE082),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('📩'),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    request.itemName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusMeta.$2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusMeta.$1,
                    style: TextStyle(
                      color: statusMeta.$3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _chip('👥 People', request.totalPerson),
                _chip('📅 Date', request.date),
                _chip('🕒 Arrival', request.arrivalTime),
                _chip('⏰ Event', request.eventTime),
                _chip(
                    '💸 ${context.tri((l) => l.fareLabel)}', request.fare),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD0F4DE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '🥕 Ingredients: ${request.ingredients}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                _buildUserDetailsButton(
                  context: context,
                  clientId: request.clientId,
                ),
                const Spacer(),
                if (status == ChefOrderStatus.active)
                  ElevatedButton.icon(
                    onPressed: () => database.orderCompleted(docId: docId),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Completed'),
                  ),
                if (status == ChefOrderStatus.pending)
                  Text(
                    'Waiting for client response',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedOrderCard({
    required BuildContext context,
    required RequestModel request,
    required String docId,
    required ChefOrderStatus status,
    required AppDatabase database,
  }) {
    final statusMeta = _statusMeta(status);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: status == ChefOrderStatus.completed
              ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
              : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: status == ChefOrderStatus.completed
              ? const Color(0xFF66BB6A)
              : const Color(0xFF64B5F6),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status == ChefOrderStatus.completed ? '✅' : '🔥',
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    request.itemName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusMeta.$2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusMeta.$1,
                    style: TextStyle(
                      color: statusMeta.$3,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                _chip('People', request.totalPerson),
                _chip('Date', request.date),
                _chip('Event', request.eventTime),
                _chip(context.tri((l) => l.fareLabel), request.fare),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Ingredients: ${request.ingredients}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildUserDetailsButton(
                  context: context,
                  clientId: request.clientId,
                ),
                const Spacer(),
                if (status == ChefOrderStatus.active)
                  ElevatedButton.icon(
                    onPressed: () => database.orderCompleted(docId: docId),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Complete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, Color) _statusMeta(ChefOrderStatus status) {
    switch (status) {
      case ChefOrderStatus.pending:
        return ('Pending', Colors.orange.shade100, Colors.orange.shade900);
      case ChefOrderStatus.active:
        return ('Active', Colors.blue.shade100, Colors.blue.shade900);
      case ChefOrderStatus.completed:
        return ('Completed', Colors.green.shade100, Colors.green.shade900);
    }
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFCC80),
          width: 1,
        ),
      ),
      child: Text('$label: $value'),
    );
  }

  Widget _buildUserDetailsButton({
    required BuildContext context,
    required String clientId,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetails(userid: clientId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF176), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFB8C00),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Text('🧍'),
            ),
            const SizedBox(width: 7),
            const Text(
              'User Details',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: Color(0xFF4E342E),
              ),
            ),
            const SizedBox(width: 4),
            const Text('✨'),
          ],
        ),
      ),
    );
  }
}
