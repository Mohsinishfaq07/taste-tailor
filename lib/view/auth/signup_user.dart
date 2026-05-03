import 'dart:io';
import 'package:taste_tailor/model/all_user_detail_model.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/model/client_detail_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import '../../widgets/language_toggle_bar.dart';
import '../../global_custom_widgets/address_location_options.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../global_custom_widgets/custom_auth_text_field.dart';

class SignupUser extends StatefulWidget {
  const SignupUser({super.key});
  static const tag = 'SignupUser';

  @override
  State<SignupUser> createState() => _SignupUserState();
}

class _SignupUserState extends State<SignupUser>
    with SingleTickerProviderStateMixin {
  bool userSelectedImage = false;
  String? _image;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AppDatabase database = AppDatabase();
  final _auth = FirebaseAuth.instance;

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
    nameController.dispose();
    numberController.dispose();
    addressController.dispose();
    gmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    const LanguageToggleBar(compact: true),
                    SizedBox(height: 12.h),
                    // Header
                    Text(
                      context.tri((l) => l.createAccount),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      context.tri((l) => l.signUpUserSubtitle),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.deepOrange.shade900.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: () => _showImagePickerBottomSheet(),
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.deepOrange.shade200.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: userSelectedImage
                              ? ClipOval(
                                  child: Image.network(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40.sp,
                                  color: Colors.deepOrange.shade300,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Form Fields
                    CustomAuthTextField(
                      controller: nameController,
                      label: context.tri((l) => l.fullName),
                      hint: context.tri((l) => l.enterFullName),
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 20.h),

                    CustomAuthTextField(
                      controller: numberController,
                      label: context.tri((l) => l.phoneNumber),
                      hint: context.tri((l) => l.enterPhone),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                    ),
                    SizedBox(height: 20.h),

                    AddressLocationOptions(addressController: addressController),
                    CustomAuthTextField(
                      controller: addressController,
                      label: context.tri((l) => l.address),
                      hint: context.tri((l) => l.enterAddress),
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 20.h),

                    CustomAuthTextField(
                      controller: gmailController,
                      label: context.tri((l) => l.email),
                      hint: context.tri((l) => l.enterEmail),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20.h),

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
                    SizedBox(height: 20.h),

                    CustomAuthTextField(
                      controller: confirmPasswordController,
                      label: context.tri((l) => l.confirmPassword),
                      hint: context.tri((l) => l.confirmYourPassword),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: 40.h),

                    // Signup Button
                    _buildButton(
                      context.tri((l) => l.signUp),
                      () {
                        if (nameController.text.isEmpty ||
                            numberController.text.isEmpty ||
                            addressController.text.isEmpty ||
                            gmailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: LocaleNotifier.toast(
                              'Please fill all fields',
                              'تمام خانے بھریئے',
                            ),
                          );
                        } else if (confirmPasswordController.text !=
                            passwordController.text) {
                          Fluttertoast.showToast(
                            msg: LocaleNotifier.toast(
                              "Passwords don't match",
                              'پاس ورڈ یکساں نہیں',
                            ),
                          );
                        } else {
                          onTapSignupUser(
                            context,
                            nameController.text,
                            numberController.text,
                            addressController.text,
                            gmailController.text,
                            passwordController.text,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 55.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.shade400,
            Colors.deepOrange.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.shade200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          height: 150.h,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomSheetOption(
                    sheetContext.tri((l) => l.pickCamera),
                    Icons.camera_alt,
                    () {
                      Navigator.pop(sheetContext);
                      _pickImageFromSource(ImageSource.camera);
                    },
                  ),
                  _buildBottomSheetOption(
                    sheetContext.tri((l) => l.pickGallery),
                    Icons.photo_library,
                    () {
                      Navigator.pop(sheetContext);
                      _pickImageFromSource(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(
      String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30.sp,
              color: Colors.deepOrange.shade300,
            ),
            SizedBox(height: 8.h),
            Text(
              text,
              style: TextStyle(
                color: Colors.deepOrange.shade700,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$filename');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      try {
        await uploadTask;
        final String downloadUrl = await storageReference.getDownloadURL();
        setState(() {
          userSelectedImage = true;
          _image = downloadUrl;
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error uploading image: $e");
      }
    }
  }

  void onTapSignupUser(
    BuildContext context,
    String name,
    String number,
    String address,
    String email,
    String pass,
  ) async {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange.shade400,
        ),
      ),
    );

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      if (!context.mounted) return;
      await database.userDetailsToFireStore(
        context: context,
        clientDetail: ClientDetailModel(
          address: address,
          email: email,
          name: name,
          number: number,
          password: pass,
          userId: _auth.currentUser!.uid,
          image: _image ?? "enable_storage",
          role: 'user',
          timestamp: Timestamp.now(),
        ),
        allUserDetail: AllUserDetailModel(
          id: _auth.currentUser!.uid,
          name: name,
          email: email,
          role: 'user',
          timestamp: Timestamp.now(),
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      Fluttertoast.showToast(msg: '$e');
    }
  }
}
