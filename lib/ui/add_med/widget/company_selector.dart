import 'package:flutter/material.dart';
import 'package:pharmacy/ui/add_med/add_med_controller.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:provider/provider.dart';

class CompanySelector extends StatelessWidget {
  const CompanySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AddMedController>();

    return SimpleDialog(
      title: const Text('Select Company'),
      children: [
        CustomFirestoreListView(
          query: controller.getCompaniesQuery(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 8),
          itemBuilder: (context, doc) {
            final company = doc.data();

            return ListTile(
              title: Text(company.name),
              onTap: () {
                Navigator.of(context).pop(company);
              },
            );
          },
        ),
      ],
    );
  }
}
