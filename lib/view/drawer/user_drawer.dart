import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/model/client_detail_model.dart';
import 'package:taste_tailor/view/all_chefs/all_chefs.dart';
import 'package:taste_tailor/view/user_screens/rehman/orders/user_orders_screen.dart';
import 'package:taste_tailor/view/chat/conversations_list_screen.dart';
import 'package:taste_tailor/view/user_screens/user_orders_calendar_screen.dart';
import 'package:taste_tailor/view/user_screens/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/widgets/language_toggle_bar.dart';
import '../../../app_assets.dart';
import '../../../utils/shared_preferences_manager.dart';
import '../dashboard/User_dashboard_request_form.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer>
    with SingleTickerProviderStateMixin {
  final AppDatabase database = AppDatabase();
  ClientDetailModel? clientDetailModel;
  String _headerDisplayName = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  Future<void> getUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() {});
      return;
    }
    clientDetailModel = await database.getUserById(docId: uid);

    final fromPrefs = await SharedPreferencesManager.getUserName();
    final auth = FirebaseAuth.instance.currentUser;

    String resolved = '';
    final profileName = clientDetailModel?.name.trim() ?? '';
    if (profileName.isNotEmpty) {
      resolved = profileName;
    } else if (fromPrefs != null && fromPrefs.trim().isNotEmpty) {
      resolved = fromPrefs.trim();
    } else if (auth != null) {
      final dn = auth.displayName?.trim();
      if (dn != null && dn.isNotEmpty) {
        resolved = dn;
      } else {
        final email = auth.email;
        if (email != null && email.contains('@')) {
          resolved = email.split('@').first;
        }
      }
    }
    if (resolved.isEmpty) {
      resolved = 'User';
    }

    _headerDisplayName = resolved;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepOrange.shade200,
              Colors.deepOrange.shade100,
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: const LanguageToggleBar(compact: true),
                      ),
                      SizedBox(height: 8.h),
                      _buildDrawerItem(
                        icon: Icons.group,
                        text: context.tri((l) => l.drawerAllChefs),
                        onTap: () => _navigateTo(context, AllChefs.tag),
                      ),
                      _buildDrawerItem(
                        icon: Icons.add_circle_outline,
                        text: context.tri((l) => l.drawerNewRequest),
                        onTap: () =>
                            _navigateTo(context, UserDashboardRequestForm.tag),
                      ),
                      _buildDrawerItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        text: context.tri((l) => l.drawerMessages),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold?.isDrawerOpen ?? false) {
                            scaffold!.closeDrawer();
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!context.mounted) return;
                            Navigator.pushNamed(
                              context,
                              ConversationsListScreen.tag,
                            );
                          });
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.receipt_long,
                        text: context.tri((l) => l.drawerMyOrders),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (navCtx) => UserOrdersScreen(
                              type: UserOrderScreenType.all,
                              title: navCtx.tri((l) => l.myOrdersTitle),
                            ),
                          ),
                        ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.calendar_month_rounded,
                        text: context.tri((l) => l.drawerOrderCalendar),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold?.isDrawerOpen ?? false) {
                            scaffold!.closeDrawer();
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!context.mounted) return;
                            Navigator.pushNamed(
                              context,
                              UserOrdersCalendarScreen.tag,
                            );
                          });
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_outline_rounded,
                        text: context.tri((l) => l.drawerMyProfile),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold?.isDrawerOpen ?? false) {
                            scaffold!.closeDrawer();
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!context.mounted) return;
                            Navigator.pushNamed(
                              context,
                              UserProfileScreen.tag,
                            ).then((_) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (mounted) getUserDetails();
                            });
                          });
                        },
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.5),
                        thickness: 1,
                        indent: 20.w,
                        endIndent: 20.w,
                      ),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        text: context.tri((l) => l.drawerLogout),
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold?.isDrawerOpen ?? false) {
                            scaffold!.closeDrawer();
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            if (!context.mounted) return;
                            await database.logout(context);
                          });
                        },
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                AppAssets.appIcon,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          if (_headerDisplayName.isNotEmpty)
            Text(
              _headerDisplayName,
              style: TextStyle(
                color: Colors.deepOrange.shade900,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              color: isLogout
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red : Colors.deepOrange.shade700,
                  size: 21.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color:
                          isLogout ? Colors.red : Colors.deepOrange.shade900,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    FocusManager.instance.primaryFocus?.unfocus();
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen ?? false) {
      scaffold!.closeDrawer();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.pushNamed(context, routeName);
    });
  }
}
