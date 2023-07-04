import 'package:flutter/material.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:pharmacy/ui/payment/payment_details_page.dart';
import 'package:pharmacy/ui/scanner/scanner_page.dart';
import 'package:provider/provider.dart';

import 'data/repository.dart';
import 'model/med.dart';
import 'theme/theme.dart';
import 'ui/add_med/add_med_page.dart';
import 'ui/auth/login/login_page.dart';
import 'ui/home/home_container.dart';
import 'ui/transaction/transaction_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in to set initial route (page) for the application
    final isUserLoggedIn = context.read<Repository>().isUserLoggedIn;

    return MaterialApp(
      title: 'Pharmacy',
      theme: theme,
      onGenerateRoute: Routes.onGenerateRoute,
      initialRoute: isUserLoggedIn ? Routes.HOME : Routes.LOGIN,
    );
  }
}

/// Class holding all Routes (Pages) information for the application.
class Routes {
  static const HOME = 'home';
  static const LOGIN = 'login';
  static const SCANNER = 'scanner';
  static const ADD_MED = 'add_med';
  static const TRANSACTION = 'transaction';
  static const PAYMENT_DETAILS = 'payment';

  /// Constant routes that require no parameters.
  static final routes = <String, Widget>{
    LOGIN: const LoginPage(),
    HOME: const HomeContainer(),
    TRANSACTION: const TransactionPage(),
  };

  /// Callback to determine which route to use when navigation.
  /// It also handles sending parameters to the page.
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

    if(routeSettings.name == PAYMENT_DETAILS) {
      final payment = routeSettings.getArgument<Payment>('payment')!;

      page = PaymentDetailsPage(payment: payment);
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

  /// Simple extension to simplify reading arguments (parameters) for pages.
  T? getArgument<T>(String key) => (mapArguments?[key] as T?);
}
