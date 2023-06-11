import 'package:flutter/material.dart';
import 'package:pharmacy/main.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/ui/home/database/widget/med_item.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:pharmacy/widget/loading_dialog.dart';
import 'package:provider/provider.dart';

import 'database_controller.dart';
import 'widget/add_category_dialog.dart';
import 'widget/add_company_dialog.dart';

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
      floatingActionButton: selectFab(currentPage),
    );
  }

  Widget selectContent(int currentPage) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(
      top: 0,
      bottom: 0,
    );

    if (currentPage == 0) {
      return CustomFirestoreListView(
        query: controller.getMedsQuery(),
        itemBuilder: (context, doc) {
          return MedItem(doc.data());
        },
      );
    } else if (currentPage == 1) {
      return CustomFirestoreListView(
        query: controller.getCategoriesQuery(),
        itemBuilder: (context, doc) {
          final category = doc.data();

          return ListTile(
            title: Text(category.name),
            subtitle: Text(category.description),
            isThreeLine: category.description.isNotEmpty,
          );
        },
      );
    } else if (currentPage == 2) {
      return CustomFirestoreListView(
        query: controller.getCompaniesQuery(),
        itemBuilder: (context, doc) {
          final company = doc.data();

          return ListTile(
            title: Text(company.name),
          );
        },
      );
    }

    return Container();
  }

  Widget? selectFab(int currentPage) {
    if (currentPage == 0) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(Routes.ADD_MED);
        },
        label: const Text('Add Medication'),
        icon: const Icon(Icons.add),
      );
    } else if (currentPage == 1) {
      return FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const AddCategoryDialog(),
          ).then((value) {
            if (value is MedCategory) {
              _addCategory(value);
            }
          });
        },
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
      );
    } else if (currentPage == 2) {
      return FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const AddCompanyDialog(),
          ).then((value) {
            if (value is MedCompany) {
              _addCompany(value);
            }
          });
        },
        label: const Text('Add Company'),
        icon: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _addCategory(MedCategory category) {
    showDialog(
      context: context,
      builder: (_) => LoadingDialog(
        future: controller.addCategory(category),
        message: 'Adding Category',
      ),
    ).then((value) {
      if (value is Exception || value is Error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getErrorText(value)),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Category added'),
        ));
      }
    });
  }

  void _addCompany(MedCompany company) {
    showDialog(
      context: context,
      builder: (_) => LoadingDialog(
        future: controller.addCompany(company),
        message: 'Adding Company',
      ),
    ).then((value) {
      if (value is Exception || value is Error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getErrorText(value)),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Company added'),
        ));
      }
    });
  }
}
