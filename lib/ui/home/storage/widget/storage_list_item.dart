import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/storage_item.dart';

class StorageListItem extends StatelessWidget {
  final StorageItem storageItem;
  final bool showDate;

  const StorageListItem(
    this.storageItem, {
    this.showDate = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = storageItem.expirationDate.isBefore(DateTime.now());
    final isExpiringSoon = storageItem.expirationDate.isBefore(DateTime.now().add(const Duration(days: 5)));

    return StreamBuilder(
      stream: storageItem.medRef
          .withConverter(
            fromFirestore: Med.fromFirestore,
            toFirestore: Med.toFirestore,
          )
          .snapshots(),
      builder: (context, snapshot) {
        Widget title;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final med = snapshot.data!.data()!;

          title = Text(med.name);
        } else {
          title = const SizedBox();
        }

        return ListTile(
          title: title,
          subtitle: showDate
              ? Text(
                  'Expires : ${DateFormat('dd-MM-yyyy').format(storageItem.expirationDate)}',
                  style: TextStyle(
                    color: isExpired ? Colors.red : (isExpiringSoon ? Colors.yellow : null),
                  ),
                )
              : null,
          trailing: Text(storageItem.amount.toString()),
        );
      },
    );
  }
}
