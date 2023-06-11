import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final medTextController = TextEditingController();
  final countTextController = TextEditingController(text: '1');

  Med? med;
  int count = 1;

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
              'Add Category',
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: medTextController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Medication',
                hintText: 'Medication',
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        FocusScope.of(context).unfocus();
                        setState(() {
                          count++;
                          countTextController.text = count.toString();
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_up),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: med != null
                  ? () {
                      Navigator.pop(
                        context,
                        {
                          'med': med,
                          'count': count,
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
}
