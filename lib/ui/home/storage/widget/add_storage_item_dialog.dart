import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/app.dart';
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
  late final controller = context.read<StorageController>();

  final medTextController = TextEditingController();
  final amountTextController = TextEditingController(text: '1');
  final expirationDateTextController = TextEditingController();

  Med? med;
  int amount = 1;
  Timestamp? expirationDate;

  @override
  Widget build(BuildContext context) {
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
              controller: amountTextController,
              keyboardType: TextInputType.number,
              onChanged: (text) {
                setState(() {
                  amount = int.parse(text);
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'Amount',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          amount++;
                          amountTextController.text = amount.toString();
                          amountTextController.selection = TextSelection.fromPosition(
                            TextPosition(offset: amount.toString().length),
                          );
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_up),
                    ),
                    IconButton(
                      onPressed: amount > 1
                          ? () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                amount--;
                                amountTextController.text = amount.toString();
                              });
                            }
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_down),
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
                          'amount': amount,
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
      final medQuery = await controller
          .getMedsQuery()
          .where(
            'barcode',
            isEqualTo: barcodeValue,
          )
          .get();

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
