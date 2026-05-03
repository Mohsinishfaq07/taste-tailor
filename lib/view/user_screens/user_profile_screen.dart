import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/global_custom_widgets/account_deletion_dialog.dart';
import 'package:taste_tailor/global_custom_widgets/profile_photo_editor.dart';
import 'package:taste_tailor/global_custom_widgets/custom_auth_text_field.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/view/drawer/user_drawer.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  static const String tag = 'UserProfileScreen';

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AppDatabase _database = AppDatabase();
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _loadingProfile = true;
  bool _loadError = false;
  bool _savingProfile = false;
  bool _updatingPassword = false;
  bool _currentPwVisible = false;
  bool _newPwVisible = false;
  bool _confirmPwVisible = false;
  String _profileImageUrl = '';
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
          _loadError = true;
        });
      }
      return;
    }

    final model = await _database.getUserById(docId: uid);
    if (!mounted) return;
    if (model == null) {
      setState(() {
        _loadingProfile = false;
        _loadError = true;
      });
      return;
    }

    _nameController.text = model.name;
    _numberController.text = model.number;
    _emailController.text =
        model.email.isNotEmpty ? model.email : (FirebaseAuth.instance.currentUser?.email ?? '');
    _profileImageUrl = model.image.trim();

    setState(() => _loadingProfile = false);
  }

  Future<void> _changeProfilePhoto() async {
    final source = await showProfilePhotoSourceSheet(
      context: context,
      galleryLabel: context.tri((l) => l.profilePhotoGallery),
      cameraLabel: context.tri((l) => l.profilePhotoCamera),
      dismissLabel: context.tri((l) => l.profilePhotoDismiss),
    );
    if (source == null || !mounted) return;

    final xfile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1536,
      maxHeight: 1536,
      imageQuality: 85,
    );
    if (xfile == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    final url = await _database.uploadProfileImage(File(xfile.path));
    if (!mounted) return;
    setState(() {
      _uploadingPhoto = false;
      if (url != null && url.trim().isNotEmpty) {
        _profileImageUrl = url.trim();
      }
    });
  }

  Future<void> _submitProfile() async {
    FocusScope.of(context).unfocus();
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    setState(() => _savingProfile = true);
    await _database.updateClientProfileFields(
      name: _nameController.text,
      number: _numberController.text,
    );
    if (mounted) setState(() => _savingProfile = false);
  }

  Future<void> _submitPassword() async {
    FocusScope.of(context).unfocus();
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    setState(() => _updatingPassword = true);
    final ok = await _database.updateClientPassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _updatingPassword = false);
    if (ok) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tri((l) => l.drawerMyProfile),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      drawer: const UserDrawer(),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9800)))
          : _loadError
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      context.tri((l) => l.profileLoadErrorBody),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.deepOrange.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _card(
                        child: Form(
                          key: _profileFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ProfilePhotoEditorBanner(
                                imageUrl: _profileImageUrl,
                                uploading: _uploadingPhoto,
                                headingLabel:
                                    context.tri((l) => l.profilePhotoHeading),
                                hintLabel:
                                    context.tri((l) => l.profilePhotoHint),
                                onChangeTap: _changeProfilePhoto,
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                context.tri((l) => l.profileAccountDetailsHeading),
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF5D4037),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              CustomAuthTextField(
                                controller: _nameController,
                                label: context.tri((l) => l.fullName),
                                hint: context.tri((l) => l.profileYourNameHint),
                                icon: Icons.person_outline_rounded,
                                validator: (v) {
                                  if (v == null || v.trim().length < 2) {
                                    return context.tri(
                                        (l) => l.profileValidatorNameShort);
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),
                              CustomAuthTextField(
                                controller: _numberController,
                                label: context.tri((l) => l.phoneNumber),
                                hint: context.tri((l) => l.enterPhone),
                                icon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().length < 5) {
                                    return context.tri(
                                        (l) => l.profileValidatorPhoneShort);
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),
                              CustomAuthTextField(
                                controller: _emailController,
                                label: context.tri((l) => l.email),
                                hint: '',
                                icon: Icons.email_outlined,
                                readOnly: true,
                              ),
                              SizedBox(height: 18.h),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepOrange.shade400,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                onPressed: _savingProfile ? null : _submitProfile,
                                child: _savingProfile
                                    ? SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      )
                                    : Text(
                                        context.tri((l) => l.profileSaveChanges),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _card(
                        child: Form(
                          key: _passwordFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.tri((l) => l.profileChangePasswordHeading),
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF5D4037),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                context.tri((l) => l.profilePasswordIntro),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.brown.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              CustomAuthTextField(
                                controller: _currentPasswordController,
                                label:
                                    context.tri((l) => l.profileCurrentPassword),
                                hint: '',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                isPasswordVisible: _currentPwVisible,
                                onTogglePassword: () => setState(
                                    () => _currentPwVisible = !_currentPwVisible),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return context.tri((l) => l.validatorRequired);
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),
                              CustomAuthTextField(
                                controller: _newPasswordController,
                                label: context.tri((l) => l.profileNewPassword),
                                hint: '',
                                icon: Icons.lock_reset_rounded,
                                isPassword: true,
                                isPasswordVisible: _newPwVisible,
                                onTogglePassword: () =>
                                    setState(() => _newPwVisible = !_newPwVisible),
                                validator: (v) {
                                  if (v == null || v.length < 6) {
                                    return context.tri(
                                        (l) => l.validatorPasswordMinSix);
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),
                              CustomAuthTextField(
                                controller: _confirmPasswordController,
                                label: context.tri(
                                    (l) => l.profileConfirmNewPassword),
                                hint: '',
                                icon: Icons.verified_outlined,
                                isPassword: true,
                                isPasswordVisible: _confirmPwVisible,
                                onTogglePassword: () => setState(
                                    () => _confirmPwVisible = !_confirmPwVisible),
                                validator: (v) {
                                  if (v != _newPasswordController.text) {
                                    return context.tri(
                                        (l) => l.validatorPasswordsNoMatchAlt);
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 18.h),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.deepOrange.shade900,
                                  side: BorderSide(
                                    color: Colors.deepOrange.shade400,
                                    width: 1.5,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                onPressed:
                                    _updatingPassword ? null : _submitPassword,
                                child: _updatingPassword
                                    ? SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.deepOrange.shade600,
                                        ),
                                      )
                                    : Text(
                                        context.tri(
                                            (l) => l.profileUpdatePasswordButton),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_rounded,
                                    color: Colors.red.shade700, size: 22.sp),
                                SizedBox(width: 10.w),
                                Text(
                                  context.tri((l) => l.profileDeleteAccountHeading),
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              context.tri((l) => l.profileDeleteAccountBlurb),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.brown.shade700,
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade800,
                                side: BorderSide(
                                  color: Colors.red.shade400,
                                  width: 1.5,
                                ),
                                padding:
                                    EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              onPressed: () =>
                                  showAccountDeletionFlow(context),
                              icon:
                                  Icon(Icons.delete_forever_rounded, size: 20.sp),
                              label: Text(
                                context.tri((l) => l.profileDeleteAccountButton),
                                style:
                                    const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 28.h),
                    ],
                  ),
                ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
