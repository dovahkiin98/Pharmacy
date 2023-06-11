import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:provider/provider.dart';

class StorageController extends ChangeNotifier {
  final Repository _repository;

  StorageController(BuildContext context) : _repository = context.read();

  Query<StorageItem> getStorageQuery() => _repository.getStorageQuery();

  Query<Med> getMedsQuery() => _repository.getMedsQuery();

  Stream<Med> getMedItemDoc(String id) => _repository.getMedItemDoc(id);

  Future addToStorage(Med med, int count) async {
    await _repository.addToStorage(med, count);
  }
}
