import 'package:taste_tailor/constants/legal_urls.dart';
import 'package:taste_tailor/view/auth/signup_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_assets.dart';
import '../widgets/language_toggle_bar.dart';
import '../global_custom_widgets/custom_large_button.dart';
import 'auth/signup_chef.dart';
import 'auth/login_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});
  static const String tag = '/GetStartedScreen';
  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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

    // Firebase setup
    _firebaseMessaging.subscribeToTopic('all').then((_) {
      print('Subscribed to topic "all"');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPrivacyPolicy() async {
    try {
      final ok = await launchUrl(
        LegalUrls.privacyPolicy,
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tri((l) => l.privacyPolicyOpenFailed)),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tri((l) => l.privacyPolicyOpenFailed)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                dialogContext.tri((l) => l.exitAppTitle),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.deepOrange.shade700,
                  fontSize: 22.sp,
                ),
              ),
              content: Text(
                dialogContext.tri((l) => l.exitAppMessage),
                style: TextStyle(
                  color: Colors.deepOrange.shade900,
                  fontSize: 16.sp,
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDialogButton(
                        dialogContext.tri((l) => l.exitNo),
                        false,
                        () => Navigator.of(dialogContext).pop(false)),
                    _buildDialogButton(dialogContext.tri((l) => l.exitYes),
                        true, () {
                      Navigator.of(dialogContext).pop(true);
                      SystemNavigator.pop();
                    }),
                  ],
                ),
              ],
            );
          },
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                // Logo with shadow
                Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.shade200.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Image.asset(AppAssets.appIcon),
                ),
                SizedBox(height: 50.h),
                // Buttons
                CustomLargeButton(
                  title: context.tri((l) => l.getStartedLogin),
                  ontap: () => onTapLogin(context),

                  backgroundColor: Colors.white,
                  textColor: Colors.deepOrange.shade700,



                ),
                SizedBox(height: 20.h),
                CustomLargeButton(
                  title: context.tri((l) => l.getStartedSignUpChef),
                  ontap: () => onTapSignUpAsAChef(context),

                ),
                SizedBox(height: 20.h),
                CustomLargeButton(
                  title: context.tri((l) => l.getStartedSignUpUser),
                  ontap: () => onTapSignUpAsAUser(context),

                ),
                SizedBox(height: 28.h),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepOrange.shade800,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _openPrivacyPolicy,
                  icon: Icon(Icons.description_outlined, size: 20.sp),
                  label: Text(
                    context.tri((l) => l.privacyPolicyLink),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.deepOrange.shade600,
                    ),
                  ),
                ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: const LanguageToggleBar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, bool primary, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: primary
                ? Colors.deepOrange.shade700
                : Colors.deepOrange.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigates to the loginScreen when the action is triggered.
void onTapLogin(BuildContext context) {
  Navigator.pushNamed(context, LoginScreen.tag);
}

/// Navigates to the signupScreen when the action is triggered.
void onTapSignUpAsAChef(BuildContext context) {
  Navigator.pushNamed(context, SignupChef.tag);
}

/// Navigates to the signupOneScreen when the action is triggered.
void onTapSignUpAsAUser(BuildContext context) {
  Navigator.pushNamed(context, SignupUser.tag);
}
