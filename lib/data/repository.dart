import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:pharmacy/model/payment_item.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:pharmacy/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository with ChangeNotifier {
  static const TIMEOUT = Duration(seconds: 8);

  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  final _flutterNotifications = FlutterLocalNotificationsPlugin();

  final SharedPreferences _prefs;
  Timer? _storageCheckJob;

  Repository(this._prefs) {
    _startStorageCheckJob();
  }

  bool get isUserLoggedIn => _prefs.getBool('loggedIn') ?? false;

  login(String email, String password) async {
    await _firebaseAuth
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(TIMEOUT);

    await _prefs.setBool('loggedIn', true);
  }

  logout() async {
    await _firebaseAuth.signOut();

    await _prefs.setBool('loggedIn', false);
  }

  Query<Med> getMedsQuery() => _firestore.collection('meds').orderBy('name').withConverter(
        fromFirestore: Med.fromFirestore,
        toFirestore: Med.toFirestore,
      );

  Stream<DocumentSnapshot<Med>> getMedItemDoc(String id) => _firestore
      .collection('meds')
      .doc(id)
      .withConverter(
        fromFirestore: Med.fromFirestore,
        toFirestore: Med.toFirestore,
      )
      .snapshots();

  Query<StorageItem> getStorageQuery() => _firestore.collection('storage').withConverter(
        fromFirestore: StorageItem.fromFirestore,
        toFirestore: StorageItem.toFirestore,
      );

  Query<MedCategory> getCategoriesQuery() => _firestore.collection('categories').orderBy('name').withConverter(
        fromFirestore: MedCategory.fromFirestore,
        toFirestore: MedCategory.toFirestore,
      );

  addCategory(MedCategory category) async {
    await _firestore.collection('categories').add(category.toJson()).timeout(TIMEOUT);
  }

  Query<MedCompany> getCompaniesQuery() => _firestore.collection('companies').orderBy('name').withConverter(
        fromFirestore: MedCompany.fromFirestore,
        toFirestore: MedCompany.toFirestore,
      );

  Stream<DocumentSnapshot<MedCompany>> getCompanyItemDoc(String id) => _firestore
      .collection('companies')
      .doc(id)
      .withConverter(
        fromFirestore: MedCompany.fromFirestore,
        toFirestore: MedCompany.toFirestore,
      )
      .snapshots();

  addCompany(MedCompany company) async {
    await _firestore.collection('companies').add(company.toJson()).timeout(TIMEOUT);
  }

  addMed(Med med) async {
    if (med.id.isEmpty) {
      await _firestore.collection('meds').add(med.toJson());
    } else {
      await _firestore.collection('meds').doc(med.id).update(med.toJson()).timeout(TIMEOUT);
    }
  }

  addToStorage(
    Med med,
    int amount,
    Timestamp expirationDate,
  ) async {
    await _firestore.collection('storage').add({
      'med': _firestore.collection('meds').doc(med.id),
      'amount': amount,
      'expirationDate': expirationDate,
    }).timeout(TIMEOUT);
  }

  Stream<QuerySnapshot<StorageItem>> getSoonToExpireQuery() => _firestore
      .collection('storage')
      .where(
        'expirationDate',
        isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        isGreaterThan: Timestamp.now(),
      )
      .withConverter(
        fromFirestore: StorageItem.fromFirestore,
        toFirestore: StorageItem.toFirestore,
      )
      .snapshots();

  Stream<QuerySnapshot<StorageItem>> getExpiredQuery() => _firestore
      .collection('storage')
      .where(
        'expirationDate',
        isLessThanOrEqualTo: Timestamp.now(),
      )
      .withConverter(
        fromFirestore: StorageItem.fromFirestore,
        toFirestore: StorageItem.toFirestore,
      )
      .snapshots();

  Stream<List<StorageItem>> getAlmostOutOfStock() => _firestore
          .collection('storage')
          .withConverter(
            fromFirestore: StorageItem.fromFirestore,
            toFirestore: StorageItem.toFirestore,
          )
          .snapshots()
          .map((event) {
        final map = <DocumentReference, int>{};

        for (var element in event.docs) {
          final storageItem = element.data();

          map[storageItem.medRef] = (map[storageItem.medRef] ?? 0) + storageItem.amount;
        }

        final filteredMap = <StorageItem>[];

        for (var MapEntry(:key, value: amount) in map.entries) {
          if (amount < 5) {
            filteredMap.add(StorageItem(
              id: '',
              amount: amount,
              medRef: key,
              expirationDate: DateTime.now(),
            ));
          }
        }

        return filteredMap;
      });

  void _startStorageCheckJob() {
    if (!kDebugMode) {
      _storageCheck();
    }

    _storageCheckJob = Timer.periodic(
      const Duration(hours: 2),
      (_) => _storageCheck(),
    );
  }

  void _storageCheck() async {
    final expiredMeds = await getExpiredQuery().first;
    final soonToExpireMed = await getSoonToExpireQuery().first;
    final almostOutOfStock = (await getAlmostOutOfStock().first);

    for (var element in expiredMeds.docs) {
      final med = await getMedItemDoc(element.data().medRef.id).first;

      await _flutterNotifications.show(
        element.id.hashCode,
        'Storage Item Expired',
        'Item "${med.data()!.name}" has expired',
        androidAlertsChannel,
      );
    }

    for (var element in soonToExpireMed.docs) {
      final med = await getMedItemDoc(element.data().medRef.id).first;

      await _flutterNotifications.show(
        element.id.hashCode,
        'Storage Item Expiring Soon',
        'Item "${med.data()!.name}" will expire in "${element.data().expirationDate.difference(DateTime.now()).inDays}" days',
        androidAlertsChannel,
      );
    }

    for (var element in almostOutOfStock) {
      final med = await getMedItemDoc(element.medRef.id).first;

      await _flutterNotifications.show(
        med.id.hashCode,
        'Storage Item almost out of stock',
        'Only ${element.amount} of item "${med.data()!.name}" remain',
        androidAlertsChannel,
      );
    }
  }

  Future createPayment(List<PaymentItem> items, String buyerName) async {
    final newDoc = _firestore.collection('payments').doc();

    await newDoc.set({
      'seller': _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid),
      'buyer': buyerName,
      'date': Timestamp.now(),
      'total': items.fold<double>(
        0,
        (previousValue, element) => previousValue + (element.individualPrice * element.amount),
      ),
    }).timeout(TIMEOUT);

    final itemsCollection = newDoc.collection('items');

    for (var element in items) {
      await itemsCollection.add(element.toJson());
    }
  }

  Query<Payment> getPaymentsQuery() => _firestore.collection('payments').withConverter(
        fromFirestore: Payment.fromFirestore,
        toFirestore: Payment.toFirestore,
      );

  @override
  void dispose() {
    super.dispose();

    _storageCheckJob?.cancel();
  }
}
