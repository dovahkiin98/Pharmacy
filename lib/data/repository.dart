import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository with ChangeNotifier {
  static const TIMEOUT = Duration(seconds: 8);

  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;

  final SharedPreferences _prefs;

  Repository(this._prefs);

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
        fromFirestore: (snapshot, _) => Med.fromJson(snapshot),
        toFirestore: (med, _) => med.toJson(),
      );

  Stream<Med> getMedItemDoc(String id) =>
      _firestore.collection('meds').doc(id).snapshots().map((event) => Med.fromJson(event));

  Query<StorageItem> getStorageQuery() => _firestore.collection('storage').withConverter(
        fromFirestore: StorageItem.fromFirestore,
        toFirestore: StorageItem.toFirestore,
      );

  Query<MedCategory> getCategoriesQuery() => _firestore.collection('categories').orderBy('name').withConverter(
        fromFirestore: MedCategory.fromFirestore,
        toFirestore: MedCategory.toFirestore,
      );

  addCategory(MedCategory category) async {
    await _firestore.collection('categories').add(category.toJson());
  }

  Query<MedCompany> getCompaniesQuery() => _firestore.collection('companies').orderBy('name').withConverter(
        fromFirestore: MedCompany.fromFirestore,
        toFirestore: MedCompany.toFirestore,
      );

  addCompany(MedCompany company) async {
    await _firestore.collection('companies').add(company.toJson());
  }

  addMed(Med med) async {
    if (med.id.isEmpty) {
      await _firestore.collection('meds').add(med.toJson());
    } else {
      await _firestore.collection('meds').doc(med.id).update(med.toJson());
    }
  }

  addToStorage(
    Med med,
    int count,
    Timestamp expirationDate,
  ) async {
    await _firestore.collection('storage').add({
      'med': _firestore.collection('med').doc(med.id),
      'count': count,
      'expirationDate': expirationDate,
    });
  }
}
