import 'package:taste_tailor/global_custom_widgets/custom_auth_text_field.dart';
import 'package:taste_tailor/services/account_deletion_service.dart';
import 'package:taste_tailor/utils/shared_preferences_manager.dart';
import 'package:taste_tailor/view/get_started_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Google Play requirement: identifiable, in-app permanent account deletion.
Future<void> showAccountDeletionFlow(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DeleteAccountAlert(),
  );
}

class _DeleteAccountAlert extends StatefulWidget {
  const _DeleteAccountAlert();

  @override
  State<_DeleteAccountAlert> createState() => _DeleteAccountAlertState();
}

class _DeleteAccountAlertState extends State<_DeleteAccountAlert> {
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _confirmed = false;
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _deletePressed() async {
    if (!_confirmed || _loading) return;
    final pw = _password.text.trim();
    if (pw.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter your password to confirm.');
      return;
    }
    final navigator = Navigator.of(context, rootNavigator: true);
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final error = await AccountDeletionService.instance
        .deleteCurrentUserAccount(password: pw);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      Fluttertoast.showToast(msg: error);
      return;
    }

    await SharedPreferencesManager.clearUserSession();
    Fluttertoast.showToast(msg: 'Your account has been deleted.');

    navigator.pop(); // Close dialog route
    navigator.pushNamedAndRemoveUntil(GetStartedScreen.tag, (_) => false);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      title: Row(
        children: [
          Icon(Icons.delete_forever_rounded,
              color: Colors.deepOrange.shade700, size: 28.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Delete account',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18.sp,
                color: Colors.deepOrange.shade900,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This permanently deletes your Taste Tailor login and removes your '
              'profile, chats linked to your account, ratings you submitted, chef '
              'offers tied to you, and order documents stored under your user ID '
              'where applicable.\n\n'
              'This cannot be undone.\n'
              'Some generic or legacy records might remain aggregated or unidentified; '
              'contact the app publisher by email listed on the Play listing if '
              'you still see personal data afterward.',
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.45,
                color: Colors.brown.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Enter your login password:',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange.shade900,
              ),
            ),
            SizedBox(height: 8.h),
            CustomAuthTextField(
              controller: _password,
              label: 'Password',
              hint: '',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              isPasswordVisible: !_obscure,
              onTogglePassword: () => setState(() => _obscure = !_obscure),
            ),
            SizedBox(height: 14.h),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmed,
              onChanged: _loading ? null : (v) => setState(() => _confirmed = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.deepOrange.shade600,
              title: Text(
                'I understand my account will be permanently deleted.',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : _cancel,
          child: Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed:
              (_loading || !_confirmed) ? null : () => _deletePressed(),
          child: _loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                )
              : const Text(
                  'Delete my account',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
        ),
      ],
    );
  }
}
