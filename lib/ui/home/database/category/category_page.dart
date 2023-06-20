import 'package:flutter/material.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:pharmacy/widget/loading_dialog.dart';
import 'package:provider/provider.dart';

import '../database_controller.dart';
import 'add_category_dialog.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

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
            builder: (context) => const AddCategoryDialog(),
          ).then((value) {
            if (value is MedCategory) {
              _addCategory(context, value);
            }
          });
        },
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _addCategory(
    BuildContext context,
    MedCategory category,
  ) {
    final controller = context.read<DatabaseController>();

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
}
