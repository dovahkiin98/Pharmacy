import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/ui/home/payments/payments_page.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboard_page.dart';
import 'database/database_page.dart';
import 'home_controller.dart';
import 'storage/storage_page.dart';

class HomeContainer extends StatelessWidget {
  const HomeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeContainerController(context),
      builder: (context, _) => buildLayout(context),
    );
  }

  Widget buildLayout(BuildContext context) {
    final scaffoldController = context.read<HomeContainerController>();

    return Scaffold(
      key: scaffoldController.scaffoldKey,
      drawer: buildDrawer(context),
      body: Navigator(
        key: scaffoldController.navigatorKey,
        initialRoute: HomeRoutes.DASHBOARD,
        onGenerateRoute: HomeRoutes.onGenerateRoute,
        observers: [scaffoldController],
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    final scaffoldController = context.watch<HomeContainerController>();
    final currentPage = scaffoldController.currentRoute;

    return NavigationDrawer(
      children: [
        DrawerHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/ic_launcher.svg',
                    width: 56,
                    height: 56,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Pharmacy',
                    style: TextStyle(fontSize: 30),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  scaffoldController.logout();
                  Navigator.of(context).popUntil((route) => false);
                  Navigator.of(context).pushNamed(Routes.LOGIN);
                },
                child: const Text('Logout'),
              )
            ],
          ),
        ),
        ListTile(
          title: const Text('Dashboard'),
          selected: currentPage == HomeRoutes.DASHBOARD,
          onTap: () {
            scaffoldController.navigateDrawer(HomeRoutes.DASHBOARD);
          },
        ),
        ListTile(
          title: const Text('Database'),
          selected: currentPage == HomeRoutes.DATABASE,
          onTap: () {
            scaffoldController.navigateDrawer(HomeRoutes.DATABASE);
          },
        ),
        ListTile(
          title: const Text('Storage'),
          selected: currentPage == HomeRoutes.STORAGE,
          onTap: () {
            scaffoldController.navigateDrawer(HomeRoutes.STORAGE);
          },
        ),
        ListTile(
          title: const Text('Payments'),
          selected: currentPage == HomeRoutes.PAYMENTS,
          onTap: () {
            scaffoldController.navigateDrawer(HomeRoutes.PAYMENTS);
          },
        ),
      ],
    );
  }
}

class HomeRoutes {
  static const DASHBOARD = 'dashboard';
  static const DATABASE = 'database';
  static const STORAGE = 'storage';
  static const PAYMENTS = 'payments';

  static final routes = {
    DASHBOARD: const DashboardPage(),
    DATABASE: const DatabasePage(),
    STORAGE: const StoragePage(),
    PAYMENTS: const PaymentsPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    final pageName = routeSettings.name;

    if (pageName != null) {
      final page = routes[pageName];

      if (page != null) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: routeSettings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 0.0, end: 1.0),
              ),
              child: child,
            );
          },
        );
      }
    }

    return null;
  }
}
