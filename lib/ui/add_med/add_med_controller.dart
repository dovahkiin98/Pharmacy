import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/model/med.dart';
import 'package:provider/provider.dart';

class AddMedController extends ChangeNotifier {
  final Repository _repository;

  Med med = Med.empty();

  AddMedController(BuildContext context) : _repository = context.read();

  Query<MedCategory> getCategoriesQuery() => _repository.getCategoriesQuery();

  Query<MedCompany> getCompaniesQuery() => _repository.getCompaniesQuery();

  updateMed(Med Function(Med) update) {
    med = update(med);

    notifyListeners();
  }

  Future addMed() async {
    _repository.addMed(med);
  }
}
