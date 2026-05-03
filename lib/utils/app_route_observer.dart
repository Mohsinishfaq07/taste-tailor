import 'package:flutter/material.dart';

/// Shared [RouteObserver] for [navigatorObservers] — used to drop keyboard
/// focus when pushing/popping routes (e.g. search fields staying active).
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
