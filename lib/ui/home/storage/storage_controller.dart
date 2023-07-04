import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:provider/provider.dart';

class StorageController extends ChangeNotifier {
  final Repository _repository;

  bool get isAdmin => _repository.isAdmin;

  StorageController(BuildContext context) : _repository = context.read();

  Query<StorageItem> getStorageQuery() {
    final query = _repository.getStorageQuery();

    return isAdmin ? query.orderBy('user') : query;
  }

  Query<Med> getMedsQuery() => _repository.getMedsQuery().orderBy('name');

  Future addToStorage(
    Med med,
    int amount,
    Timestamp expirationDate,
  ) async {
    await _repository.addToStorage(
      med,
      amount,
      expirationDate,
    );
  }

  Future removeFromStorage(StorageItem storageItem) => _repository.removeFromStorage(storageItem);
}
