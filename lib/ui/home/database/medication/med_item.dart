import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/model/med.dart';

class MedItem extends StatelessWidget {
  final Med med;
  final VoidCallback? onTap;

  const MedItem(
    this.med, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(med.name),
      subtitle: Text(
        med.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: med.description.isNotEmpty,
      trailing: Text(NumberFormat.currency(
        locale: 'en',
        symbol: 'SYP',
        decimalDigits: 0,
        customPattern: '###,### \u00A4',
      ).format(med.price)),
      onTap: onTap,
    );
  }
}
