import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/model/med.dart';
import 'package:provider/provider.dart';

class DatabaseController extends ChangeNotifier {
  final Repository _repository;

  DatabaseController(BuildContext context) : _repository = context.read();

  Query<Med> getMedsQuery() => _repository.getMedsQuery();

  Query<MedCategory> getCategoriesQuery() => _repository.getCategoriesQuery();

  Future addCategory(MedCategory category) async {
    await _repository.addCategory(category);

    return true;
  }

  Query<MedCompany> getCompaniesQuery() => _repository.getCompaniesQuery();

  Stream<DocumentSnapshot<MedCompany>> getCompanyItemDoc(String id) => _repository.getCompanyItemDoc(id);

  Future addCompany(MedCompany company) async {
    await _repository.addCompany(company);

    return true;
  }
}
