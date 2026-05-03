import 'package:taste_tailor/model/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../widgets/language_toggle_bar.dart';
import '../../global_custom_widgets/custom_large_button.dart';
import '../../global_custom_widgets/custom_auth_text_field.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String tag = "LoginScreen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AppDatabase database = AppDatabase();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(showBackButton: true),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  const LanguageToggleBar(compact: true),
                  SizedBox(height: 18.h),
                  // Welcome Text
                  Text(
                    context.tri((l) => l.welcomeBack),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade700,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    context.tri((l) => l.signInContinue),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.deepOrange.shade900.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Email Field
                  CustomAuthTextField(
                    controller: emailController,
                    label: context.tri((l) => l.email),
                    hint: context.tri((l) => l.enterEmail),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.h),

                  // Password Field
                  CustomAuthTextField(
                    controller: passwordController,
                    label: context.tri((l) => l.password),
                    hint: context.tri((l) => l.enterPassword),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => onTapForgotPassword(context),
                      child: Text(
                        context.tri((l) => l.forgotPassword),
                        style: TextStyle(
                          color: Colors.deepOrange.shade700,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Login Button
                  Center(
                    child: CustomLargeButton(
                      title: context.tri((l) => l.login),
                      ontap: () {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: LocaleNotifier.toast(
                              'Please fill all fields',
                              'تمام خانے بھریئے',
                            ),
                          );
                        } else {
                          database.signIn(
                            emailController.text,
                            passwordController.text,
                            context,
                          );
                        }
                      },



                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onTapForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, ForgotPassword.tag);
  }
}
