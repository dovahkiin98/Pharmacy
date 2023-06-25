import 'package:flutter/material.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/widget/custom_track_shape.dart';

class AddCompanyDialog extends StatefulWidget {
  const AddCompanyDialog({super.key});

  @override
  State<AddCompanyDialog> createState() => _AddCompanyDialogState();
}

class _AddCompanyDialogState extends State<AddCompanyDialog> {
  final nameController = TextEditingController();
  int _quality = 1;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(
      top: 0,
    );

    return BottomSheet(
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: viewPadding +
              const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 26,
              ),
          children: [
            Text(
              'Add Company',
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              onChanged: (_) {
                setState(() {});
              },
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Name',
              ),
            ),
            const SizedBox(height: 24),
            Text('Company Quality ($_quality)'),
            SliderTheme(
              data: SliderThemeData(
                trackShape: CustomTrackShape(),
              ),
              child: Slider(
                value: _quality.toDouble(),
                label: _quality.toString(),
                min: 1,
                max: 10,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _quality = value.toInt();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: nameController.text.trim().isNotEmpty
                  ? () {
                      Navigator.pop(
                        context,
                        MedCompany(
                          id: '',
                          name: nameController.text.trim(),
                          quality: _quality,
                        ),
                      );
                    }
                  : null,
              child: const Text('Add Company'),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      onClosing: () {},
    );
  }
}
