import 'package:flutter/material.dart';
import 'package:taste_tailor/utils/app_route_observer.dart';

/// Unfocuses primary focus when this route is covered by another route or when
/// a route above was popped ([didPopNext]) so search fields stop blinking.
mixin UnfocusOnRouteCoverMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPopNext() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPop() {}

  @override
  void didPush() {}
}
