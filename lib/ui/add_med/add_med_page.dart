import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/ui/add_med/add_med_controller.dart';
import 'package:pharmacy/ui/add_med/widget/company_selector.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:pharmacy/widget/loading_dialog.dart';
import 'package:provider/provider.dart';

import 'widget/category_selector.dart';

class AddMedPage extends StatelessWidget {
  final Med? med;

  const AddMedPage({
    this.med,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddMedController(context, med: med),
      builder: (context, child) => _AddMedPage(),
    );
  }
}

class _AddMedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddMedPageState();
}

class _AddMedPageState extends State<_AddMedPage> {
  late final controller = context.watch<AddMedController>();

  late final priceTextController = controller.priceTextController;
  late final categoryTextController = controller.categoryTextController;
  late final companyTextController = controller.companyTextController;
  late final barcodeTextController = controller.barcodeTextController;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(top: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
      ),
      body: ListView(
        padding: viewPadding + const EdgeInsets.all(16),
        children: [
          TextFormField(
            initialValue: controller.med.name,
            onChanged: (text) {
              controller.updateMed(
                (med) => med.copyWith(name: text),
              );
            },
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Name',
              labelText: 'Name',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: controller.med.description,
            maxLines: 3,
            onChanged: (text) {
              controller.updateMed(
                (med) => med.copyWith(description: text),
              );
            },
            decoration: const InputDecoration(
              hintText: 'Description',
              labelText: 'Description',
            ),
          ),
          const SizedBox(height: 16),
          Focus(
            onFocusChange: (isFocused) {
              if (isFocused) {
                priceTextController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: priceTextController.text.length,
                );
              }
            },
            child: TextFormField(
              controller: priceTextController,
              onChanged: (text) {
                controller.updateMed(
                  (med) => med.copyWith(price: double.tryParse(text) ?? 0),
                );
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Price',
                labelText: 'Price',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: barcodeTextController,
            maxLength: 13,
            decoration: InputDecoration(
              hintText: 'Barcode',
              labelText: 'Barcode',
              suffixIcon: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.SCANNER,
                    arguments: {
                      'exitOnScan': true,
                    },
                  ).then((value) {
                    if (value is String) {
                      controller.updateMed((med) => med.copyWith(barcode: value));
                      barcodeTextController.text = value.trim();
                    }
                  });
                },
                tooltip: "Scan Barcode",
                icon: const Icon(Icons.barcode_reader),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: categoryTextController,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'Category',
              labelText: 'Category',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ChangeNotifierProvider.value(
                  value: controller,
                  child: const CategorySelector(),
                ),
              ).then((value) {
                if (value is MedCategory) {
                  controller.updateMed(
                    (med) => med.copyWith(
                      categoryRef: FirebaseFirestore.instance.collection('categories').doc(value.id),
                    ),
                  );
                  categoryTextController.text = value.name;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: companyTextController,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'Company',
              labelText: 'Company',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ChangeNotifierProvider.value(
                  value: controller,
                  child: const CompanySelector(),
                ),
              ).then((value) {
                if (value is MedCompany) {
                  controller.updateMed(
                    (med) => med.copyWith(
                      companyRef: FirebaseFirestore.instance.collection('companies').doc(value.id),
                    ),
                  );
                  companyTextController.text = value.name;
                }
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _validateInput() ? _addMed : null,
            child: Text(!controller.isUpdate ? 'Add Medication' : 'Update Medication'),
          ),
        ],
      ),
    );
  }

  bool _validateInput() {
    final med = controller.med;

    return med.name.isNotEmpty && med.categoryRef != null && med.companyRef != null;
  }

  void _addMed() {
    showDialog(
      context: context,
      builder: (_) => LoadingDialog(
        future: controller.addMed(),
        message: !controller.isUpdate ? 'Adding Medication' : 'Updating Medication',
      ),
    ).then((value) {
      if (value is Exception || value is Error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getErrorText(value)),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(!controller.isUpdate ? 'Medication added' : 'Medication Updated'),
        ));

        Navigator.of(context).pop();
      }
    });
  }
}
