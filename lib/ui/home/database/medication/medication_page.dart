import 'package:flutter/material.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:provider/provider.dart';

import '../database_controller.dart';
import 'med_item.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DatabaseController>();

    return Scaffold(
      body: CustomFirestoreListView(
        query: controller.getMedsQuery(),
        itemBuilder: (_, doc) {
          return MedItem(
            doc.data(),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.viewPaddingOf(context) +
                        const EdgeInsets.only(
                          bottom: 16,
                          top: 32,
                        ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Edit'),
                          leading: const Icon(Icons.edit),
                          onTap: () {
                            Navigator.pop(context, 0);
                            Navigator.of(context, rootNavigator: true).pushNamed(
                              Routes.ADD_MED,
                              arguments: {'med': doc.data()},
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Delete'),
                          leading: const Icon(Icons.delete),
                          onTap: () {
                            Navigator.pop(context, 1);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(Routes.ADD_MED);
        },
        label: const Text('Add Medication'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
