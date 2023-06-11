import 'package:flutter/material.dart';
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
      subtitle: Text(med.description),
      isThreeLine: med.description.isNotEmpty,
      onTap: onTap,
    );
  }
}
