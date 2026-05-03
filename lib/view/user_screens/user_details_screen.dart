import 'package:taste_tailor/global_custom_widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../global_custom_widgets/custom_title_text.dart';
import '../../model/client_detail_model.dart';
import '../auth/forgot_password.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key, this.userid});
  static const String tag = "UserDetails";
  final String? userid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Column(
          children: [
            const CustomTitleText(text: 'User Details'),
            SizedBox(height: 10.h),
            if (userid == null || userid!.isEmpty)
              _buildMissingUserState()
            else
              RequestCard(user: userid!),
            const Spacer(),
            const BottomRightImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingUserState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
      ),
      child: const Text(
        'No user selected',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF6D4C41),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.user});
  final String user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('allusers').doc(user).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 10.h),
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildMessageCard(
            text: 'Oops! ${snapshot.error}',
            icon: '⚠️',
            bg: const Color(0xFFFFEBEE),
            border: const Color(0xFFEF9A9A),
          );
        }
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return _buildMessageCard(
            text: 'No user details found',
            icon: '😕',
            bg: const Color(0xFFFFF3E0),
            border: const Color(0xFFFFCC80),
          );
        }

        final clientDetail = ClientDetailModel.fromJson(
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF176), Color(0xFFFFCC80)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFB8C00), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: const Text('🧑', style: TextStyle(fontSize: 28)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientDetail.name.isEmpty
                              ? 'Unknown User'
                              : clientDetail.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        _miniTag('✨ Verified Profile'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _infoBubble('📍 Address', clientDetail.address),
              SizedBox(height: 7.h),
              _infoBubble('📞 Number', clientDetail.number),
              SizedBox(height: 7.h),
              _infoBubble('📧 Email', clientDetail.email),
              SizedBox(height: 7.h),
              _infoBubble('👤 Role', clientDetail.role),
            ],
          ),
        );
      },
    );
  }

  Widget _miniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6D4C41),
        ),
      ),
    );
  }

  Widget _infoBubble(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF5D4037),
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required String text,
    required String icon,
    required Color bg,
    required Color border,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(
        '$icon  $text',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6D4C41),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
