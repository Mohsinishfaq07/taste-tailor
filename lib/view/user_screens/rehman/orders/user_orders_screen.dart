import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/model/request_model.dart';
import 'package:taste_tailor/view/chef_screens/chef_details_screen.dart';
import 'package:taste_tailor/view/drawer/user_drawer.dart';
import 'package:taste_tailor/view/rating_screens/rating_screen.dart';
import 'package:taste_tailor/utils/unfocus_on_route_cover_mixin.dart';
import 'package:taste_tailor/utils/order_date_expiry.dart';

enum UserOrderScreenType { all, pending, assigned, completed, expired }

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({
    super.key,
    required this.type,
    required this.title,
  });

  final UserOrderScreenType type;
  final String title;

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen>
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

  List<QueryDocumentSnapshot<Object?>> _filterOrdersByItemName(
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
      padding: EdgeInsets.only(bottom: 6.h),
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
            hintText: context.tri((l) => l.userOrdersSearchHint),
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
                    onPressed: () => _searchController.clear(),
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
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      drawer: const UserDrawer(),
      body: user == null
          ? Center(child: Text(context.tri((l) => l.pleaseSignInAgain)))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('food_orders')
                          .where('clientId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, foodSnapshot) {
                        if (foodSnapshot.hasError) {
                          return Text(context.tri((l) =>
                              l.errorWithMessage('${foodSnapshot.error}')));
                        }
                        if (!foodSnapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.pink.shade200,
                            ),
                          );
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('requests')
                              .where('clientId', isEqualTo: user.uid)
                              .snapshots(),
                          builder: (context, requestsSnapshot) {
                            if (requestsSnapshot.hasError) {
                              return Text(context.tri((l) => l.errorWithMessage(
                                  '${requestsSnapshot.error}')));
                            }
                            if (!requestsSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.pink.shade200,
                                ),
                              );
                            }

                            final docs = [
                              ...foodSnapshot.data!.docs,
                              ...requestsSnapshot.data!.docs,
                            ].where((doc) {
                              final acceptedChiefId =
                                  doc['acceptedChiefId'] as String? ?? '';
                              final orderStatus =
                                  doc['orderStatus'] as String? ?? '';

                              switch (widget.type) {
                                case UserOrderScreenType.all:
                                  return true;
                                case UserOrderScreenType.pending:
                                  final st = orderStatus.trim().toLowerCase();
                                  return acceptedChiefId == 'noChiefSelected' &&
                                      (orderStatus == 'notAssigned' ||
                                          orderStatus == 'Pending' ||
                                          st == 'expired');
                                case UserOrderScreenType.assigned:
                                  return acceptedChiefId != 'noChiefSelected' &&
                                      orderStatus == 'assigned';
                                case UserOrderScreenType.completed:
                                  return acceptedChiefId != 'noChiefSelected' &&
                                      orderStatus == 'completed';
                                case UserOrderScreenType.expired: {
                                  if (acceptedChiefId != 'noChiefSelected') {
                                    return false;
                                  }
                                  final data = doc.data();
                                  if (data is! Map<String, dynamic>) {
                                    return false;
                                  }
                                  final r =
                                      RequestModel.fromJson(Map<String, dynamic>.from(data));
                                  return isOpenOrderExpired(r);
                                }
                              }
                            }).toList()
                              ..sort((a, b) {
                                final ta = (a.data() as Map<String, dynamic>)[
                                    'timestamp'];
                                final tb = (b.data() as Map<String, dynamic>)[
                                    'timestamp'];
                                if (ta is Timestamp && tb is Timestamp) {
                                  return tb.compareTo(ta);
                                }
                                return 0;
                              });

                            if (docs.isEmpty) {
                              return Center(child: Text(_emptyMessage(context)));
                            }

                            final searchDocs =
                                _filterOrdersByItemName(docs);
                            if (searchDocs.isEmpty) {
                              return Center(
                                child: Text(context.tri((l) => l.noOrdersMatchSearch)),
                              );
                            }

                            return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        itemCount: searchDocs.length,
                        itemBuilder: (context, index) {
                          final request = RequestModel.fromJson(
                            searchDocs[index].data()
                                as Map<String, dynamic>,
                          );
                          final docId = searchDocs[index].id;
                          final hasChefResponse = request.chefResponses.isNotEmpty;
                          final selectedResponse =
                              hasChefResponse ? request.chefResponses.first : null;
                          final chefId =
                              request.acceptedChiefId != 'noChiefSelected'
                                  ? request.acceptedChiefId
                                  : (selectedResponse?['userId']?.toString() ??
                                      '');

                          final cardType = _getCardType(request);

                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF6CC), Color(0xFFFFE1F0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFFFFB74D),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF9800)
                                      .withValues(alpha: 0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 10.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFC1E3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text('🍽️'),
                                      ),
                                      SizedBox(width: 7.w),
                                      Expanded(
                                        child: Text(
                                          request.itemName.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF5D4037),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      _buildStatusBadge(context, cardType),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: [
                                      _detailPill(
                                          '👨‍👩‍👧',
                                          context.tri((l) => l.orderDetailPeopleShort),
                                          request.totalPerson),
                                      _detailPill(
                                          '📅',
                                          context.tri((l) => l.orderDetailDateShort),
                                          request.date),
                                      _detailPill(
                                          '🕒',
                                          context.tri(
                                              (l) => l.orderDetailArrivalShort),
                                          request.arrivalTime),
                                      _detailPill(
                                          '⏰',
                                          context.tri((l) => l.orderDetailEventShort),
                                          request.eventTime),
                                      _detailPill(
                                        '💸',
                                        context.tri((l) => l.orderDetailFareShort),
                                        hasChefResponse
                                            ? selectedResponse!['fare']
                                                .toString()
                                            : (request.fare.isNotEmpty
                                                ? request.fare
                                                : context.tri(
                                                    (l) => l.orderListFarePending)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD0F4DE),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF7BCFA6),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.tri(
                                              (l) => l.orderCardIngredientsHeading),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          request.ingredients,
                                          style: const TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  if (chefId.isNotEmpty)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF7E57C2),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChefDetailsScreen(
                                              userid: chefId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Text('🧑‍🍳'),
                                      label: Text(
                                        context.tri((l) => l.orderViewChefDetails),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3CD),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFFD54F),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        context.tri((l) => l.orderWaitingChefAcceptance),
                                        style: const TextStyle(
                                          color: Color(0xFF8D6E00),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 4.h),
                                  _buildFooter(
                                    context: context,
                                    type: cardType,
                                    hasChefResponse: hasChefResponse,
                                    chefId: chefId,
                                    docId: docId,
                                    database: database,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _emptyMessage(BuildContext context) {
    switch (widget.type) {
      case UserOrderScreenType.all:
        return context.tri((l) => l.emptyOrdersAll);
      case UserOrderScreenType.pending:
        return context.tri((l) => l.emptyOrdersPending);
      case UserOrderScreenType.expired:
        return context.tri((l) => l.emptyOrdersExpired);
      case UserOrderScreenType.assigned:
        return context.tri((l) => l.emptyOrdersAssigned);
      case UserOrderScreenType.completed:
        return context.tri((l) => l.emptyOrdersCompleted);
    }
  }

  Widget _buildFooter({
    required BuildContext context,
    required UserOrderScreenType type,
    required bool hasChefResponse,
    required String chefId,
    required String docId,
    required AppDatabase database,
  }) {
    if (type == UserOrderScreenType.expired) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(Icons.event_busy_rounded,
                color: Colors.brown.shade700, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                context.tri((l) => l.orderExpiredLine),
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (type == UserOrderScreenType.pending) {
      if (!hasChefResponse || chefId.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            context.tri((l) => l.orderWaitingChefOffers),
            style: TextStyle(
              color: Colors.deepOrange.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFCDD2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFB71C1C)),
              onPressed: () => database.rejectByClient(
                docId: docId,
                chiefId: chefId,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFC8E6C9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF1B5E20)),
              onPressed: () => database.acceptedByClient(
                docId: docId,
                chiefId: chefId,
              ),
            ),
          ),
        ],
      );
    }

    if (type == UserOrderScreenType.completed && chefId.isNotEmpty) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4DB6AC),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RatingScreen(chefId: chefId),
            ),
          );
        },
        child: Text(
          context.tri((l) => l.rateChefButton),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  UserOrderScreenType _getCardType(RequestModel r) {
    final orderStatus = r.orderStatus.trim();
    if (orderStatus == 'completed') {
      return UserOrderScreenType.completed;
    }
    if (r.acceptedChiefId != 'noChiefSelected' && orderStatus == 'assigned') {
      return UserOrderScreenType.assigned;
    }
    if (isOpenOrderExpired(r)) {
      return UserOrderScreenType.expired;
    }
    return UserOrderScreenType.pending;
  }

  String _statusLabel(BuildContext context, UserOrderScreenType cardType) {
    switch (cardType) {
      case UserOrderScreenType.pending:
        return context.tri((l) => l.orderStatusPending);
      case UserOrderScreenType.expired:
        return context.tri((l) => l.orderStatusExpired);
      case UserOrderScreenType.assigned:
        return context.tri((l) => l.orderStatusAssigned);
      case UserOrderScreenType.completed:
        return context.tri((l) => l.orderStatusCompleted);
      case UserOrderScreenType.all:
        return context.tri((l) => l.orderStatusUnknown);
    }
  }

  Widget _buildStatusBadge(
      BuildContext context, UserOrderScreenType cardType) {
    Color bg;
    Color fg;
    switch (cardType) {
      case UserOrderScreenType.pending:
        bg = const Color(0xFFFFE082);
        fg = const Color(0xFF6D4C41);
        break;
      case UserOrderScreenType.expired:
        bg = const Color(0xFFECEFF1);
        fg = const Color(0xFF455A64);
        break;
      case UserOrderScreenType.assigned:
        bg = const Color(0xFF81D4FA);
        fg = const Color(0xFF01579B);
        break;
      case UserOrderScreenType.completed:
        bg = const Color(0xFFA5D6A7);
        fg = const Color(0xFF1B5E20);
        break;
      case UserOrderScreenType.all:
        bg = Colors.grey.shade200;
        fg = Colors.black87;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(context, cardType),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _detailPill(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
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
}
