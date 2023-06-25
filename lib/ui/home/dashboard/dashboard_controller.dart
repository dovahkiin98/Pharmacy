import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:provider/provider.dart';

class DashboardController extends ChangeNotifier {
  final Repository _repository;

  DashboardController(BuildContext context) : _repository = context.read();

  Stream<QuerySnapshot<StorageItem>> getSoonToExpire() => _repository.getSoonToExpireQuery();

  Stream<QuerySnapshot<StorageItem>> getExpired() => _repository.getExpiredQuery();

  Stream<List<StorageItem>> getAlmostOutOfStock() => _repository.getAlmostOutOfStock();
}
