// ignore_for_file: must_be_immutable, unused_element, avoid_types_as_parameter_names

import 'package:taste_tailor/global_custom_widgets/custom_app_bar.dart';
import 'package:taste_tailor/model/chief_detail_model.dart';
import 'package:taste_tailor/services/messaging_eligibility_service.dart';
import 'package:taste_tailor/view/chat/chat_conversation_screen.dart';
import 'package:taste_tailor/view/dashboard/User_dashboard_request_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChefDetailsScreen extends StatefulWidget {
  ChefDetailsScreen({super.key, this.userid});
  static const String tag = 'ChefDetails';
  String? userid;

  @override
  State<ChefDetailsScreen> createState() => _ChefDetailsScreenState();
}

class _ChefDetailsScreenState extends State<ChefDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color _ink = Color(0xFF4E342E);
  static const Color _inkSoft = Color(0xFF5D4037);
  static const Color _border = Color(0xFFFB8C00);
  static const Color _chipBorder = Color(0xFFFFA726);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1, curve: Curves.easeOutCubic),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.userid;
    if (uid == null || uid.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBarWidget(
          showBackButton: true,
          title: 'Chef Details',
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'No chef selected',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _inkSoft,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
        title: 'Chef Details',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 24.h),
            physics: const BouncingScrollPhysics(),
            child: _ChefCartoonDetailCard(
              chefDocId: uid,
              ink: _ink,
              inkSoft: _inkSoft,
              border: _border,
              chipBorder: _chipBorder,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChefCartoonDetailCard extends StatelessWidget {
  const _ChefCartoonDetailCard({
    required this.chefDocId,
    required this.ink,
    required this.inkSoft,
    required this.border,
    required this.chipBorder,
  });

  final String chefDocId;
  final Color ink;
  final Color inkSoft;
  final Color border;
  final Color chipBorder;

  Stream<List<Map<String, dynamic>>> _ratingsStream(String id) {
    return FirebaseFirestore.instance
        .collection('chef_ratings')
        .where('chefId', isEqualTo: id)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  static double _avgRating(List<Map<String, dynamic>> ratings) {
    if (ratings.isEmpty) return 0;
    final sum = ratings.fold<double>(
      0,
      (a, r) => a + ((r['rating'] as num?)?.toDouble() ?? 0),
    );
    return sum / ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('allusers')
          .doc(chefDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _loadingBox(context);
        }
        if (snapshot.hasError) {
          return _messageBox(context, 'Oops! ${snapshot.error}', Icons.error_outline_rounded);
        }
        final doc = snapshot.data;
        if (doc == null || !doc.exists || doc.data() == null) {
          return _messageBox(
            context,
            'Chef not found',
            Icons.person_search_rounded,
          );
        }

        final userData = ChiefDetailModel.fromJson(doc.data()!);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.r),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF176), Color(0xFFFFCC80)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: border, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context, userData),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle('📋 Chef profile'),
                      SizedBox(height: 8.h),
                      _infoPill(context, '🧑‍🍳 Experience', userData.workExperience),
                      _infoPill(context, '🍽️ Specialties', userData.specialties),
                      _infoPill(context, '📍 Address', userData.address),
                      _infoPill(context, '📞 Phone', userData.number),
                      _infoPill(context, '📧 Email', userData.email),
                      SizedBox(height: 12.h),
                      _bookChefButton(context, userData),
                      SizedBox(height: 14.h),
                      _sectionTitle('📜 Certificate'),
                      SizedBox(height: 8.h),
                      _certificateFrame(context, userData.certificateImage),
                      _messageChefSection(context),
                      SizedBox(height: 12.h),
                      _reviewsBlock(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _bookChefButton(BuildContext context, ChiefDetailModel userData) {
    final chefId = userData.userId.trim().isNotEmpty
        ? userData.userId.trim()
        : chefDocId;
    if (chefId.isEmpty) return const SizedBox.shrink();

    final displayName =
        userData.name.trim().isNotEmpty ? userData.name.trim() : 'Chef';

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          final logged = FirebaseAuth.instance.currentUser;
          if (logged == null) {
            Fluttertoast.showToast(msg: 'Please sign in to book a chef.');
            return;
          }
          if (logged.uid == chefId) {
            Fluttertoast.showToast(msg: 'You cannot book yourself.');
            return;
          }
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => UserDashboardRequestForm(
                preferredChefId: chefId,
                preferredChefName: displayName,
              ),
            ),
          );
        },
        icon: Icon(Icons.calendar_month_rounded, size: 20.sp),
        label: Text(
          'Book this chef',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE65100),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ChiefDetailModel userData) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(userData.image),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData.name.isEmpty ? 'Chef' : userData.name,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w900,
                    color: ink,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _chip('👨‍🍳 Star chef'),
                    if (userData.specialties.trim().isNotEmpty)
                      _chip('✨ Yum zone'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String imageUrl) {
    return Container(
      width: 88.w,
      height: 88.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.88),
        border: Border.all(color: chipBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: border.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person_rounded, size: 40.sp, color: Colors.brown),
              )
            : Icon(Icons.person_rounded, size: 40.sp, color: Colors.brown),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipBorder, width: 1.2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: inkSoft,
        ),
      ),
    );
  }

  Widget _infoPill(BuildContext context, String label, String raw) {
    final value = raw.trim().isEmpty ? 'N/A' : raw;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.35,
              color: inkSoft,
            ),
            children: [
              TextSpan(
                text: '$label\n',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _certificateFrame(BuildContext context, String url) {
    return Container(
      height: 130.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📄', style: TextStyle(fontSize: 36.sp)),
                  SizedBox(height: 6.h),
                  Text(
                    'No certificate yet',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: inkSoft,
                    ),
                  ),
                ],
              ),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  "🖼️ Can't load image",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: inkSoft,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _messageChefSection(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null || me.uid == chefDocId) {
      return SizedBox(height: 4.h);
    }
    return FutureBuilder<bool>(
      future: MessagingEligibilityService.instance.canChatPair(me.uid, chefDocId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: Center(
              child: SizedBox(
                width: 26.w,
                height: 26.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.deepOrange.shade400,
                ),
              ),
            ),
          );
        }
        final allowed = snap.data ?? false;
        if (!allowed) {
          return Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.speaker_notes_off_rounded,
                    color: Colors.brown.shade500,
                    size: 22.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Messaging is unavailable — create an active booking request '
                      'or renew your offer window. Finished, cancelled, or expired '
                      'offers cannot be messaged.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(top: 14.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatConversationScreen(
                      peerUserId: chefDocId,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE65100), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_rounded,
                          color: Colors.white, size: 22.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'Message chef 💬',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _reviewsBlock(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ratingsStream(chefDocId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return _reviewsShell(
            child: Row(
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.deepOrange.shade400,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Loading reviews…',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: inkSoft,
                  ),
                ),
              ],
            ),
          );
        }
        final ratings = snap.data ?? [];
        if (ratings.isEmpty) {
          return _reviewsShell(
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'No ratings yet — be the first to taste & review!',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final avg = _avgRating(ratings);

        return _reviewsShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8.w),
                  Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: ink,
                    ),
                  ),
                  Text(
                    '  •  ${ratings.length} foodie reviews',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: inkSoft,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ...ratings.map((r) => _reviewTile(r)),
            ],
          ),
        );
      },
    );
  }

  Widget _reviewsShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _reviewTile(Map<String, dynamic> rating) {
    final review = rating['review']?.toString() ?? '';
    final stars = (rating['rating'] as num?)?.toDouble() ?? 0;
    final quote = review.isEmpty ? '(No comment)' : review;
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE082).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${stars.toStringAsFixed(1)}★',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFEF6C00),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '"$quote"',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: inkSoft,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: chipBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange.shade400,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _messageBox(BuildContext context, String text, IconData icon) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: chipBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48.sp, color: const Color(0xFFFFB74D)),
          SizedBox(height: 12.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
