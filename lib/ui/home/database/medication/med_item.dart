import 'package:flutter/material.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/utils/constants.dart';

class MedListTile extends StatelessWidget {
  final Med med;
  final VoidCallback? onTap;

  const MedListTile(
    this.med, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(med.name),
      subtitle: med.description.isNotEmpty
          ? Text(
              med.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      isThreeLine: med.description.isNotEmpty,
      trailing: Text(getCurrencyFormat().format(med.price)),
      onTap: onTap,
    );
  }
}
