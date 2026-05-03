import 'package:taste_tailor/global_custom_widgets/custom_small_buttons.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/model/client_detail_model.dart';
import 'package:taste_tailor/model/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import 'package:taste_tailor/utils/tri_localization.dart';

import '../../services/app_interstitial_ads.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../global_custom_widgets/custom_auth_text_field.dart';
import '../../global_custom_widgets/custom_horizontal_line.dart';
import '../../global_custom_widgets/custom_large_button.dart';
import '../../global_custom_widgets/custom_size.dart';
import '../../global_custom_widgets/custom_text_form_field.dart';
import '../../global_custom_widgets/custom_title_text.dart';
import '../drawer/user_drawer.dart';
import '../user_screens/rehman/orders/user_orders_screen.dart';

class UserDashboardRequestForm extends StatefulWidget {
  const UserDashboardRequestForm({
    super.key,
    this.preferredChefId,
    this.preferredChefName,
  });

  /// When set, request is only surfaced to this chef until assigned.
  final String? preferredChefId;
  final String? preferredChefName;

  static const tag = 'UserDashboardRequestForm';

  @override
  State<UserDashboardRequestForm> createState() =>
      _UserDashboardRequestFormState();
}

class _UserDashboardRequestFormState extends State<UserDashboardRequestForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();
  final TextEditingController eventTimeController = TextEditingController();
  final TextEditingController noOfPeopleController = TextEditingController();
  final TextEditingController fareController = TextEditingController();
  final TextEditingController availableIngController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TimeOfDay? selectedArrivalTime;
  TimeOfDay? selectedEventTime;
  final AppDatabase database = AppDatabase();
  final User? user = FirebaseAuth.instance.currentUser;
  String image = '';
  String name = '';
  ClientDetailModel? clientDetailModel;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    getClientDetails();
  }

  void _setupAnimations() {
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    itemNameController.dispose();
    dateController.dispose();
    arrivalTimeController.dispose();
    eventTimeController.dispose();
    noOfPeopleController.dispose();
    fareController.dispose();
    availableIngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _showExitDialog(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBarWidget(
          title: (widget.preferredChefId ?? '').trim().isNotEmpty
              ? context.tri((l) => l.bookAChefTitle)
              : context.tri((l) => l.createRequestTitle),
          showDrawerButton: true,
        ),
        drawer: const UserDrawer(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final homeBar = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20.w,
          16.h,
          20.w,
          // Extra space below submit; scaffold already resizes when keyboard opens — do not also add viewInsets.bottom or spacing doubles badly.
          28.h + homeBar,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((widget.preferredChefId ?? '').trim().isNotEmpty) ...[
                _buildPreferredChefBanner(),
                SizedBox(height: 14.h),
              ],
              _buildTextField(
                controller: itemNameController,
                label: context.tri((l) => l.foodItemName),
                hint: context.tri((l) => l.enterFoodItem),
                icon: Icons.fastfood_outlined,
              ),
              _buildDatePicker(),
              _buildTimePicker(
                controller: arrivalTimeController,
                label: context.tri((l) => l.arrivalTimeLabel),
                hint: context.tri((l) => l.selectTimeHint),
                onTap: _selectTime,
              ),
              _buildTimePicker(
                controller: eventTimeController,
                label: context.tri((l) => l.eventTimeLabel),
                hint: context.tri((l) => l.selectTimeHint),
                onTap: () => _selectEventTime(context),
              ),
              _buildTextField(
                controller: noOfPeopleController,
                label: context.tri((l) => l.numberOfPeople),
                hint: context.tri((l) => l.enterPeopleCount),
                icon: Icons.groups_outlined,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              _buildTextField(
                controller: fareController,
                label: context.tri((l) => l.fareLabel),
                hint: context.tri((l) => l.enterFare),
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              _buildTextField(
                controller: availableIngController,
                label: context.tri((l) => l.availableIngredientsLabel),
                hint: context.tri((l) => l.ingredientsHint),
                icon: Icons.kitchen_outlined,
                maxLines: 3,
              ),
              SizedBox(height: 20.h),
              Center(
                child: CustomLargeButton(
                  title: context.tri((l) => l.submitRequest),
                  ontap: _submitRequest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferredChefBanner() {
    final name = (widget.preferredChefName ?? '').trim().isNotEmpty
        ? widget.preferredChefName!.trim()
        : context.tri((l) => l.thisChefLabel);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_pin_circle_outlined,
            color: Colors.deepOrange.shade700,
            size: 26.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '${context.tri((l) => l.bookingForChefLine1(name))}\n${context.tri((l) => l.bookingForChefLine2)}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: const Color(0xFF5D4037),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: CustomAuthTextField(
        controller: controller,
        label: label,
        hint: hint,
        icon: icon,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        readOnly: keyboardType == TextInputType.none,
        onTap: onTap,
        suffixIcon: suffixIcon,
        validator: (value) {
          if (value == null || value.isEmpty) {
            final n = context.read<LocaleNotifier>();
            return TriLocalization.triSilent(
              n,
              (l) => l.pleaseEnterField(label),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return _buildTextField(
      controller: dateController,
      label: context.tri((l) => l.dateLabel),
      hint: context.tri((l) => l.selectDateHint),
      icon: Icons.calendar_today_outlined,
      keyboardType: TextInputType.none,
      onTap: () => _selectDate(context),
      suffixIcon: IconButton(
        icon: Icon(Icons.calendar_today, color: Colors.deepOrange.shade400),
        onPressed: () => _selectDate(context),
      ),
    );
  }

  Widget _buildTimePicker({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return _buildTextField(
      controller: controller,
      label: label,
      hint: hint,
      icon: Icons.access_time,
      keyboardType: TextInputType.none,
      onTap: onTap,
      suffixIcon: IconButton(
        icon: Icon(Icons.access_time, color: Colors.deepOrange.shade400),
        onPressed: onTap,
      ),
    );
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext dlgContext) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading indicator
                  CircularProgressIndicator(color: Colors.deepOrange.shade400),
                  SizedBox(height: 20.h),
                  Text(
                    dlgContext.tri((l) => l.processingRequest),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      try {
        await database.requestToFireStore(
          context: context,
          requestModel: RequestModel(
            itemName: itemNameController.text,
            date: dateController.text,
            arrivalTime: arrivalTimeController.text,
            eventTime: eventTimeController.text,
            totalPerson: noOfPeopleController.text,
            fare: fareController.text,
            ingredients: availableIngController.text,
            clientId: user!.uid,
            acceptedChiefId: 'noChiefSelected',
            preferredChiefId: (widget.preferredChefId ?? '').trim(),
            preferredChefName: (widget.preferredChefName ?? '').trim(),
            chefResponses: [],
            timestamp: Timestamp.now(),
            orderStatus: 'notAssigned',
          ),
        );

        if (!mounted) return;
        // Show success dialog
        Navigator.pop(context); // Dismiss loading dialog
        if (!mounted) return;

        final isDirected = (widget.preferredChefId ?? '').trim().isNotEmpty;
        final bookedName =
            (widget.preferredChefName ?? context.tri((l) => l.theChefFallback))
                .trim();

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dlgContext) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 50.sp),
                    SizedBox(height: 20.h),
                    Text(
                      dlgContext.tri((l) => l.requestSubmittedSuccess),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      isDirected
                          ? dlgContext.tri(
                              (l) => l.requestSentSpecificChef(bookedName),
                            )
                          : dlgContext.tri((l) => l.requestSentAvailableChefs),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dlgContext); // Dismiss success dialog
                        await AppInterstitialAds.showThen(() {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (navCtx) => UserOrdersScreen(
                                type: UserOrderScreenType.all,
                                title: navCtx.tri((l) => l.myOrdersTitle),
                              ),
                            ),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        dlgContext.tri((l) => l.okButton),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } catch (e) {
        if (!mounted) return;
        // Show error dialog
        Navigator.pop(context); // Dismiss loading dialog
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext errContext) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 50.sp),
                    SizedBox(height: 20.h),
                    Text(
                      errContext.tri((l) => l.errorTitle),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      errContext.tri((l) => l.submitRequestFailed),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(errContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        errContext.tri((l) => l.okButton),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  Future<bool> _showExitDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (exitContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exitContext.tri((l) => l.exitFormTitle),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  exitContext.tri((l) => l.exitFormMessage),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        exitContext.tri((l) => l.cancelButton),
                        () => Navigator.of(exitContext).pop(false),
                        isCancel: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildDialogButton(
                        exitContext.tri((l) => l.exitConfirmButton),
                        () => Navigator.of(exitContext).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return shouldPop ?? false;
  }

  Widget _buildDialogButton(
    String text,
    VoidCallback onTap, {
    bool isCancel = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: isCancel ? Colors.grey.shade200 : Colors.deepOrange.shade400,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCancel ? Colors.black87 : Colors.white,
              fontSize: 13.5.sp,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getClientDetails() async {
    clientDetailModel = await database.getUserById(docId: user!.uid);
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour % 12 == 0
        ? 12
        : tod.hour % 12; // Convert 24-hour time to 12-hour
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  void _selectTime() async {
    if (selectedEventTime == null) {
      Fluttertoast.showToast(
        msg: LocaleNotifier.toast(
          'Please select the event time first',
          'پہلے تقریب کا وقت چنیں',
        ),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Check if arrival time is at least 1 hour before event time
      final now = DateTime.now();
      final eventTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedEventTime!.hour,
        selectedEventTime!.minute,
      );
      final arrivalTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      if (arrivalTime.isBefore(eventTime.subtract(const Duration(hours: 1)))) {
        setState(() {
          selectedArrivalTime = picked;
          arrivalTimeController.text = formatTimeOfDay(picked);
        });
      } else {
        Fluttertoast.showToast(
          msg: LocaleNotifier.toast(
            'Arrival time must be at least 1 hour before event time',
            'پہنچنے کا وقت تقریب سے کم از کم ایک گھنٹہ پہلے ہونا چاہیے',
          ),
        );
      }
    }
  }

  Future<void> _selectEventTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedEventTime = picked;
        eventTimeController.text = formatTimeOfDay(picked);
      });
    }
  }
}
