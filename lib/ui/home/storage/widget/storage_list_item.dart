import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:pharmacy/model/user.dart';
import 'package:provider/provider.dart';

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
    final repository = context.read<Repository>();

    final isExpired = storageItem.expirationDate.isBefore(DateTime.now());
    final isExpiringSoon = storageItem.expirationDate.isBefore(DateTime.now().add(const Duration(days: 5)));

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (repository.isAdmin)
            StreamBuilder(
              stream: storageItem.userRef
                  .withConverter(
                    fromFirestore: PharmacyUser.fromFirestore,
                    toFirestore: PharmacyUser.toFirestore,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  final user = snapshot.data!.data()!;

                  return Text(user.name);
                } else {
                  return const SizedBox();
                }
              },
            ),
          StreamBuilder(
            stream: storageItem.medRef
                .withConverter(
                  fromFirestore: Med.fromFirestore,
                  toFirestore: Med.toFirestore,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                final med = snapshot.data!.data()!;

                return Text(med.name);
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
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
  }
}
