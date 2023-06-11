import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/ui/home/database/widget/med_item.dart';
import 'package:pharmacy/ui/home/storage/storage_controller.dart';
import 'package:pharmacy/widget/error_view.dart';
import 'package:provider/provider.dart';

class MedicationSelector extends StatefulWidget {
  const MedicationSelector({super.key});

  @override
  State<MedicationSelector> createState() => _MedicationSelectorState();
}

class _MedicationSelectorState extends State<MedicationSelector> {
  List<Med>? meds;
  Object? _error;

  StreamSubscription? _listener;

  @override
  void initState() {
    super.initState();

    final controller = context.read<StorageController>();
    _listener = controller.getMedsQuery().snapshots().listen(onMedsChanged)
      ..onError(
        (e) {
          setState(() {
            _error = e;
          });
        },
      );
  }

  @override
  void dispose() {
    super.dispose();

    _listener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select Medication'),
      contentPadding: const EdgeInsets.only(
        top: 12,
        bottom: 24,
      ),
      children: [
        if (meds != null)
          ...meds!.map((e) {
            return MedItem(
              e,
              onTap: () {
                Navigator.of(context).pop(e);
              },
            );
          })
        else if (_error != null)
          ErrorView(error: _error!)
        else
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  void onMedsChanged(QuerySnapshot<Med> event) {
    setState(() {
      meds = event.docs.map((e) => e.data()).toList(growable: false);
    });
  }
}
