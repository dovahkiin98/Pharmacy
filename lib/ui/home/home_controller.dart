import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'home_container.dart';

class HomeContainerController extends NavigatorObserver with ChangeNotifier {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final navigatorKey = GlobalKey<NavigatorState>();

  static const String _initialRoute = HomeRoutes.DASHBOARD;

  HomeContainerController(BuildContext context) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  String currentRoute = _initialRoute;

  NavigatorState get _navigatorState => navigatorKey.currentState!;

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void navigateDrawer(String routeName) {
    _navigatorState.pushReplacementNamed(routeName);
    scaffoldKey.currentState!.closeDrawer();
    currentRoute = routeName;

    notifyListeners();
  }

  Future<bool> maybePop() async {
    if (await _navigatorState.maybePop()) {
      return false;
    }

    if (currentRoute != _initialRoute) {
      _navigatorState.pushReplacementNamed(_initialRoute);
      currentRoute = _initialRoute;
      return false;
    }

    return true;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) {
      if (route.settings.name != currentRoute) {
        currentRoute = route.settings.name!;

        notifyListeners();
      }
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route is PageRoute && previousRoute is PageRoute) {
      currentRoute = previousRoute.settings.name!;

      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (hasListeners) {
      super.notifyListeners();
    }
  }
}
