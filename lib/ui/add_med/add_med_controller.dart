import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/model/med.dart';
import 'package:provider/provider.dart';

class AddMedController extends ChangeNotifier {
  final Repository _repository;

  final priceTextController = TextEditingController();
  final categoryTextController = TextEditingController();
  final companyTextController = TextEditingController();
  final barcodeTextController = TextEditingController();

  Med med = Med.empty();

  bool get isUpdate => med.id.isNotEmpty;

  AddMedController(
    BuildContext context, {
    Med? med,
  }) : _repository = context.read() {
    if (med != null) {
      this.med = med;

      Future.sync(() async {
        priceTextController.text = med.price.toStringAsFixed(0);

        categoryTextController.text = (await med.categoryRef!
                    .withConverter(
                      fromFirestore: MedCategory.fromFirestore,
                      toFirestore: MedCategory.toFirestore,
                    )
                    .get())
                .data()
                ?.name ??
            '';

        companyTextController.text = (await med.companyRef!
                    .withConverter(
                      fromFirestore: MedCompany.fromFirestore,
                      toFirestore: MedCompany.toFirestore,
                    )
                    .get())
                .data()
                ?.name ??
            '';

        barcodeTextController.text = med.barcode;
      });
    }

    if (kDebugMode && med == null) {
      barcodeTextController.text = '6211212030103';
    }
  }

  Query<MedCategory> getCategoriesQuery() => _repository.getCategoriesQuery().orderBy('name');

  Query<MedCompany> getCompaniesQuery() => _repository.getCompaniesQuery().orderBy('name');

  updateMed(Med Function(Med med) update) {
    med = update(med);

    notifyListeners();
  }

  Future addMed() async {
    _repository.addMed(med);
  }
}
