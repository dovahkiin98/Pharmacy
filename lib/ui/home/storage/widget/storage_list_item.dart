import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:pharmacy/ui/home/storage/storage_controller.dart';
import 'package:provider/provider.dart';

class StorageListItem extends StatelessWidget {
  final StorageItem storageItem;

  const StorageListItem(
    this.storageItem, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<StorageController>();

    return StreamBuilder(
      stream: controller.getMedItemDoc(storageItem.medRef.id),
      builder: (context, snapshot) {
        Widget title;

        if (snapshot.hasData) {
          final med = snapshot.data!;

          title = Text(med.name);
        } else {
          title = const SizedBox();
        }

        return ListTile(
          title: title,
          subtitle: Text('Expires : ${DateFormat('dd-MM-yyyy').format(storageItem.expirationDate)}'),
          trailing: Text(storageItem.count.toString()),
        );
      },
    );
  }
}
