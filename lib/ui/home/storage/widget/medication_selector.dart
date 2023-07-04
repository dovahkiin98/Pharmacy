import 'package:flutter/material.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/ui/home/database/medication/med_item.dart';
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

  @override
  void initState() {
    super.initState();

    context.read<Repository>().getMedsQuery().get().then(
      (meds) {
        setState(() {
          this.meds = meds.docs.map((e) => e.data()).toList(growable: false);
        });
      },
      onError: (e) {
        setState(() {
          _error = e;
        });
      },
    );
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
            return MedListTile(
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
}
