import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/payment_item.dart';
import 'package:provider/provider.dart';

class TransactionController extends ChangeNotifier {
  final Repository _repository;
  final items = <PaymentItem>[];

  TransactionController(BuildContext context) : _repository = context.read() {
    if (kDebugMode) {
      items.add(PaymentItem(
        medRef: _repository.getMedItemDoc('ipeUBnuPmqvU8DUk2PoC'),
        amount: 5,
        individualPrice: 1600,
      ));
    }
  }

  Stream<DocumentSnapshot<Med>> getMedItemDoc(String id) => _repository.getMedItemDoc(id).snapshots();

  Future addByBarcode(String barcode) async {
    final medQuery = await _repository.getMedsQuery().where('barcode', isEqualTo: barcode).get();

    if (medQuery.size > 0) {
      final medRef = medQuery.docs.first.reference;

      await addMed(medRef);
    } else {
      throw 'Med not found';
    }
  }

  Future addMed(DocumentReference<Med> medRef) async {
    final med = (await medRef.get()).data()!;

    final storageItems = await _repository
        .getStorageQuery()
        .where(
          'med',
          isEqualTo: medRef,
        )
        .get();

    var itemsInStock = storageItems.docs.fold(
      0,
      (previousValue, element) => previousValue + element.data().amount,
    );

    // Find if this medication already exists in the items
    if (items.any((element) => element.medRef == medRef)) {
      final item = items.firstWhere((element) => element.medRef == medRef);
      final index = items.indexOf(item);

      if (itemsInStock < item.amount + 1) {
        throw 'Out of stock';
      }

      items[index] = item.copyWith(amount: item.amount + 1);
    } else {
      if (itemsInStock == 0) {
        throw 'Out of stock';
      }

      items.add(
        PaymentItem(
          medRef: medRef,
          amount: 1,
          individualPrice: med.price,
        ),
      );
    }

    notifyListeners();
  }

  Future removeMed(DocumentReference<Med> medRef) async {
    final med = (await medRef.get()).data()!;

    final item = items.firstWhere((element) => element.medRef == medRef);
    final index = items.indexOf(item);

    final newAmount = item.amount - 1;
    if (newAmount > 0) {
      items[index] = item.copyWith(amount: newAmount);
    } else {
      items.removeAt(index);
    }

    notifyListeners();
  }

  Future createPayment(String buyerName) async {
    await _repository.createPayment(items, buyerName);
  }
}
