import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final IconData? icon;
  final bool showBackButton;
  final bool showDrawerButton; // Add this line

  const CustomAppBarWidget({
    this.title,
    this.icon,
    this.showBackButton = false,
    this.showDrawerButton = false, // Add this line
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(50.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.deepOrange.shade200, // Navigation bar
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      leading: showDrawerButton // Check if the drawer button should be shown
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          : showBackButton
              ? IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                )
              : null,
      title: Text(
        title ?? "",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: icon != null ? [Icon(icon)] : null,
    );
  }
}
