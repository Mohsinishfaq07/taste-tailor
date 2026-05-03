import 'package:taste_tailor/model/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import '../../app_assets.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../global_custom_widgets/custom_horizontal_line.dart';
import '../../global_custom_widgets/custom_large_button.dart';
import '../../global_custom_widgets/custom_text_form_field.dart';
import '../../global_custom_widgets/custom_title_text.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});
  static const String tag = "ForgotPassword";

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  AppDatabase database = AppDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              CustomTitleText(
                text: context.tri((l) => l.forgotPasswordScreenTitle),
              ),
              CustomTextField(
                controller: numberController,
                hintText: context.tri((l) => l.enterEmail),
                keyboardType: TextInputType.emailAddress,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.036.h),
                child: const CustomHorizontalDivider(),
              ),
              CustomLargeButton(title: context.tri((l) => l.submit), ontap: () {
                if(numberController.text.isEmpty){
                  Fluttertoast.showToast(
                    msg: LocaleNotifier.toast(
                      'please enter your email!',
                      'اپنا ای میل درج کریں!',
                    ),
                  );
                }
                else{
                  database.resetPassword(context, numberController.text);
                }
              }),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.03.h), // Adjust spacing as needed
              const BottomRightImage(),
            ]),
          ),
        ),
      ),
    );
  }
}

class BottomRightImage extends StatelessWidget {
  const BottomRightImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Image.asset(
        AppAssets.appIcon,
        height: MediaQuery.of(context).size.height * 0.17.h,
      ),
    );
  }
}
