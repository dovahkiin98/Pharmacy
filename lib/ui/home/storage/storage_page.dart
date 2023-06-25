import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:pharmacy/ui/home/storage/widget/add_storage_item_dialog.dart';
import 'package:pharmacy/ui/home/storage/widget/storage_list_item.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:pharmacy/widget/loading_dialog.dart';
import 'package:provider/provider.dart';

import 'storage_controller.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StorageController(context),
      builder: (context, child) {
        return _StoragePage();
      },
    );
  }
}

class _StoragePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StoragePageState();
}

class _StoragePageState extends State<_StoragePage> {
  late final controller = context.watch<StorageController>();

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(top: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        leading: DrawerButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: CustomFirestoreListView(
        query: controller.getStorageQuery(),
        itemBuilder: (context, doc) {
          final storageItem = doc.data();

          return StorageListItem(storageItem);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: const AddStorageItemDialog(),
            ),
          ).then((value) {
            if (value is Map<String, dynamic>) {
              _addStorageItem(
                value['med'] as Med,
                value['amount'] as int,
                value['expirationDate'] as Timestamp,
              );
            }
          });
        },
        label: const Text('Add item to storage'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _addStorageItem(
    Med med,
    int amount,
    Timestamp expirationDate,
  ) {
    showDialog(
      context: context,
      builder: (_) => LoadingDialog(
        future: controller.addToStorage(med, amount, expirationDate),
        message: 'Adding to storage',
      ),
    ).then((value) {
      if (value is Exception || value is Error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getErrorText(value)),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Added to storage'),
        ));
      }
    });
  }
}
