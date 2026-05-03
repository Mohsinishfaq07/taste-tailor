import 'package:taste_tailor/view/all_chefs/all_chefs.dart';
import 'package:taste_tailor/view/dashboard/chef_dashboard_screen.dart';
import 'package:taste_tailor/view/chef_screens/chef_myorders_screen.dart.dart';
import 'package:taste_tailor/view/chef_screens/chef_orders_calendar_screen.dart';
import 'package:taste_tailor/view/chef_screens/chef_profile_screen.dart';
import 'package:taste_tailor/view/chef_screens/chef_request_queue_screen.dart';
import 'package:taste_tailor/view/auth/signup_chef.dart';
import 'package:taste_tailor/view/user_screens/user_details_screen.dart';
import 'package:taste_tailor/view/user_screens/user_requestqueue_screen.dart';
import 'package:taste_tailor/view/auth/forgot_password.dart';
import 'package:taste_tailor/view/get_started_screen.dart';
import 'package:taste_tailor/view/auth/login_screen.dart';
import 'package:taste_tailor/view/rating_screens/rating_screen.dart';
import 'package:taste_tailor/view/dashboard/User_dashboard_request_form.dart';
import 'package:taste_tailor/view/auth/signup_user.dart';
import 'package:taste_tailor/view/chat/chat_conversation_screen.dart';
import 'package:taste_tailor/view/chat/conversations_list_screen.dart';
import 'package:taste_tailor/view/splash_screen.dart';
import 'package:taste_tailor/view/user_screens/user_orders_calendar_screen.dart';
import 'package:taste_tailor/view/user_screens/user_profile_screen.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import 'package:taste_tailor/utils/tri_localization.dart';
import 'package:taste_tailor/app_navigator_key.dart';
import 'package:taste_tailor/utils/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_tailor/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  String getInitialRoute() {
    return SplashScreen.tag;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) {
        return Consumer<LocaleNotifier>(
          builder: (context, localeNotifier, _) {
            return MaterialApp(
              navigatorKey: tasteTailorNavigatorKey,
              locale: localeNotifier.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.transparent,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepOrange.shade200,
                        Colors.deepOrange.shade100,
                        Colors.white,
                        Colors.white.withOpacity(0.8),
                      ],
                      stops: const [0.1, 0.4, 0.7, 1.0],
                    ),
                  ),
                  child: child!,
                );
              },
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (ctx) {
                final s = LocaleNotifier.scoped;
                if (s != null) {
                  return TriLocalization.tri(s, (l) => l.appTitle);
                }
                return AppLocalizations.of(ctx)?.appTitle ?? 'Bawarchi App';
              },
              navigatorObservers: [appRouteObserver],
              initialRoute: getInitialRoute(),
              onGenerateRoute: _generateRoute,
            );
          },
        );
      },
    );
  }
}

Route _generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.tag:
      return _createRightToLeftRoute(const SplashScreen(), settings);
    case GetStartedScreen.tag:
      return _createRightToLeftRoute(const GetStartedScreen(), settings);
    case LoginScreen.tag:
      return _createRightToLeftRoute(const LoginScreen(), settings);
    case ForgotPassword.tag:
      return _createRightToLeftRoute(const ForgotPassword(), settings);
    case SignupUser.tag:
      return _createRightToLeftRoute(const SignupUser(), settings);
    case SignupChef.tag:
      return _createRightToLeftRoute(const SignupChef(), settings);
    case UserDashboardRequestForm.tag:
      String? preferredChefId;
      String? preferredChefName;
      final args = settings.arguments;
      if (args is Map) {
        preferredChefId = args['preferredChefId'] as String?;
        preferredChefName = args['preferredChefName'] as String?;
      }
      return _createRightToLeftRoute(
        UserDashboardRequestForm(
          preferredChefId: preferredChefId,
          preferredChefName: preferredChefName,
        ),
        settings,
      );
    case ChefDashboardScreen.tag:
      return _createRightToLeftRoute(const ChefDashboardScreen(), settings);
    case RatingScreen.tag:
      return _createRightToLeftRoute(const RatingScreen(), settings);
    case UserMyOrdersScreen.tag:
      return _createRightToLeftRoute(UserMyOrdersScreen(), settings);
    // case UserRequestQueueScreen.tag:
    //   return _createRightToLeftRoute(const UserRequestQueueScreen(), settings);
    case ChiefRequestQueueScreen.tag:
      return _createRightToLeftRoute(ChiefRequestQueueScreen(), settings);
    case ChefMyOrderScreen.tag:
      return _createRightToLeftRoute(const ChefMyOrderScreen(), settings);
    case ChefProfileScreen.tag:
      return _createRightToLeftRoute(const ChefProfileScreen(), settings);
    case ChefOrdersCalendarScreen.tag:
      return _createRightToLeftRoute(
        const ChefOrdersCalendarScreen(),
        settings,
      );
    // case PendingRequestScreen.tag:
    //   return _createRightToLeftRoute(const PendingRequestScreen(), settings);
    case AllChefs.tag:
      return _createRightToLeftRoute(AllChefs(), settings);
    case UserDetails.tag:
      return _createRightToLeftRoute(UserDetails(), settings);
    case UserProfileScreen.tag:
      return _createRightToLeftRoute(const UserProfileScreen(), settings);
    case UserOrdersCalendarScreen.tag:
      return _createRightToLeftRoute(
        const UserOrdersCalendarScreen(),
        settings,
      );
    case ConversationsListScreen.tag:
      return _createRightToLeftRoute(const ConversationsListScreen(), settings);
    case ChatConversationScreen.tag:
      final peerId = settings.arguments as String?;
      if (peerId == null || peerId.isEmpty) {
        return _createRightToLeftRoute(const SplashScreen(), settings);
      }
      return _createRightToLeftRoute(
        ChatConversationScreen(peerUserId: peerId),
        settings,
      );

    // Add other routes here
    default:
      return _createRightToLeftRoute(const SplashScreen(), settings);
  }
}

PageRoute _createRightToLeftRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
