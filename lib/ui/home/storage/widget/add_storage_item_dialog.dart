import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/ui/home/storage/storage_controller.dart';
import 'package:pharmacy/ui/home/storage/widget/medication_selector.dart';
import 'package:provider/provider.dart';

class AddStorageItemDialog extends StatefulWidget {
  const AddStorageItemDialog({super.key});

  @override
  State<AddStorageItemDialog> createState() => _AddStorageItemDialogState();
}

class _AddStorageItemDialogState extends State<AddStorageItemDialog> {
  late final _repository = context.read<Repository>();

  final medTextController = TextEditingController();
  final countTextController = TextEditingController(text: '1');
  final expirationDateTextController = TextEditingController();

  Med? med;
  int count = 1;
  Timestamp? expirationDate;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<StorageController>();

    return BottomSheet(
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 26,
          ),
          children: [
            Text(
              'Add to Storage',
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: medTextController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Medication',
                hintText: 'Medication',
                suffixIcon: IconButton(
                  onPressed: showScanner,
                  tooltip: "Scan Barcode",
                  icon: const Icon(Icons.barcode_reader),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: controller,
                    child: const MedicationSelector(),
                  ),
                ).then((value) {
                  if (value is Med) {
                    setState(() {
                      med = value;
                      medTextController.text = value.name;
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: countTextController,
              keyboardType: TextInputType.number,
              onChanged: (text) {
                setState(() {
                  count = int.parse(text);
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: InputDecoration(
                labelText: 'Count',
                hintText: 'Count',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: count > 1
                          ? () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                count--;
                                countTextController.text = count.toString();
                              });
                            }
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          count++;
                          countTextController.text = count.toString();
                          countTextController.selection = TextSelection.fromPosition(
                            TextPosition(offset: count.toString().length),
                          );
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_up),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: expirationDateTextController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Expiration Date',
                hintText: 'Expiration Date',
                suffixIcon: Icon(Icons.date_range),
              ),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 500)),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      expirationDate = Timestamp.fromDate(value);
                      expirationDateTextController.text = DateFormat('dd-MM-yyyy').format(value);
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: med != null && expirationDate != null
                  ? () {
                      Navigator.pop(
                        context,
                        {
                          'med': med,
                          'count': count,
                          'expirationDate': expirationDate,
                        },
                      );
                    }
                  : null,
              child: const Text('Add Med'),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      onClosing: () {},
    );
  }

  void showScanner() async {
    final barcodeValue = await Navigator.of(context, rootNavigator: true).pushNamed(
      Routes.SCANNER,
      arguments: {
        'exitOnScan': true,
      },
    );

    if (barcodeValue is String) {
      final medQuery = await _repository.getMedsQuery().where('barcode', isEqualTo: barcodeValue).get();

      if (medQuery.size > 0) {
        setState(() {
          med = medQuery.docs.first.data();
          medTextController.text = med!.name;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Medication not found in database'),
          ));
        }
      }
    }
  }
}
