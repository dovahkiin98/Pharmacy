import 'package:flutter/material.dart';
import 'package:pharmacy/model/category.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(
      top: 0,
    );

    return BottomSheet(
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: viewPadding + const EdgeInsets.symmetric(
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
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Description',
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: nameController.text.trim().isNotEmpty
                  ? () {
                      Navigator.pop(
                        context,
                        MedCategory(
                          id: '',
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                        ),
                      );
                    }
                  : null,
              child: const Text('Add Category'),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      onClosing: () {},
    );
  }
}
