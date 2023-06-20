import 'package:flutter/material.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/ui/home/database/company/add_company_dialog.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:pharmacy/widget/loading_dialog.dart';
import 'package:provider/provider.dart';

import '../database_controller.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DatabaseController>();

    return Scaffold(
      body: CustomFirestoreListView(
        query: controller.getCategoriesQuery(),
        itemBuilder: (context, doc) {
          final category = doc.data();

          return ListTile(
            title: Text(category.name),
            subtitle: Text(category.description),
            isThreeLine: category.description.isNotEmpty,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const AddCompanyDialog(),
          ).then((value) {
            if (value is MedCompany) {
              _addCompany(context, value);
            }
          });
        },
        label: const Text('Add Company'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _addCompany(
    BuildContext context,
    MedCompany company,
  ) {
    final controller = context.read<DatabaseController>();

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
