import 'package:flutter/material.dart';
import 'package:pharmacy/model/company.dart';

class AddCompanyDialog extends StatefulWidget {
  const AddCompanyDialog({super.key});

  @override
  State<AddCompanyDialog> createState() => _AddCompanyDialogState();
}

class _AddCompanyDialogState extends State<AddCompanyDialog> {
  final nameController = TextEditingController();

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
            OutlinedButton(
              onPressed: nameController.text.trim().isNotEmpty
                  ? () {
                      Navigator.pop(
                        context,
                        MedCompany(
                          id: '',
                          name: nameController.text.trim(),
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
