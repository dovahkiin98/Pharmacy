import 'package:flutter/material.dart';
import 'package:pharmacy/ui/home/database/category/category_page.dart';
import 'package:pharmacy/ui/home/database/company/company_page.dart';
import 'package:pharmacy/ui/home/database/medication/medication_page.dart';
import 'package:provider/provider.dart';

import 'database_controller.dart';

class DatabasePage extends StatelessWidget {
  const DatabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DatabaseController(context),
      builder: (context, child) {
        return _DatabasePage();
      },
    );
  }
}

class _DatabasePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<_DatabasePage> {
  late final controller = context.watch<DatabaseController>();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database'),
        leading: DrawerButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Meds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.branding_watermark),
            label: 'Companies',
          ),
        ],
        onTap: (page) {
          setState(() {
            currentPage = page;
          });
        },
      ),
      body: selectContent(currentPage),
    );
  }

  Widget selectContent(int currentPage) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(
      top: 0,
      bottom: 0,
    );

    if (currentPage == 0) {
      return const MedicationsPage();
    } else if (currentPage == 1) {
      return const CategoriesPage();
    } else if (currentPage == 2) {
      return const CompaniesPage();
    }

    return Container();
  }
}
