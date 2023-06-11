import 'package:flutter/material.dart';
import 'package:pharmacy/ui/add_med/add_med_controller.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:provider/provider.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AddMedController>();

    return SimpleDialog(
      title: const Text('Select Category'),
      children: [
        CustomFirestoreListView(
          query: controller.getCategoriesQuery(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 8),
          itemBuilder: (context, doc) {
            final category = doc.data();

            return ListTile(
              title: Text(category.name),
              onTap: () {
                Navigator.of(context).pop(category);
              },
            );
          },
        ),
      ],
    );
  }
}
