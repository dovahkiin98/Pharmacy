import 'package:flutter/material.dart';
import 'package:pharmacy/ui/scanner/scanner_page.dart';
import 'package:provider/provider.dart';

import 'data/repository.dart';
import 'model/med.dart';
import 'theme/theme.dart';
import 'ui/add_med/add_med_page.dart';
import 'ui/auth/login/login_page.dart';
import 'ui/home/home_container.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = context.read<Repository>().isUserLoggedIn;

    return MaterialApp(
      title: 'Pharmacy',
      theme: theme,
      onGenerateRoute: Routes.onGenerateRoute,
      initialRoute: isUserLoggedIn ? Routes.HOME : Routes.LOGIN,
    );
  }
}

class Routes {
  static const HOME = 'home';
  static const LOGIN = 'login';
  static const SCANNER = 'scanner';
  static const ADD_MED = 'add_med';

  static final routes = <String, Widget>{
    LOGIN: const LoginPage(),
    HOME: const HomeContainer(),
  };

  static Route? onGenerateRoute(RouteSettings routeSettings) {
    Widget? page;

    if (routeSettings.name == SCANNER) {
      final exitOnScan = routeSettings.getArgument<bool>('exitOnScan') ?? false;

      page = ScannerPage(exitOnScan: exitOnScan);
    }

    if (routeSettings.name == ADD_MED) {
      final med = routeSettings.getArgument<Med>('med');

      page = AddMedPage(med: med);
    }

    page ??= routes[routeSettings.name];

    if (page != null) {
      return MaterialPageRoute(builder: (context) => page!);
    }

    return null;
  }
}

extension RouteSettingsX on RouteSettings {
  Map<String, dynamic>? get mapArguments => arguments as Map<String, dynamic>?;

  T? getArgument<T>(String key) => (mapArguments?[key] as T?);
}
