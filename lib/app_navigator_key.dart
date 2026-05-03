import 'package:flutter/material.dart';

/// Used so FCM foreground handlers always have a mounted navigator context.
final GlobalKey<NavigatorState> tasteTailorNavigatorKey =
    GlobalKey<NavigatorState>();
