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
        fromFirestore: (snapshot, _) => StorageItem.fromJson(snapshot),
        toFirestore: (storageItem, _) => storageItem.toJson(),
      );

  Query<MedCategory> getCategoriesQuery() => _firestore.collection('categories').orderBy('name').withConverter(
        fromFirestore: (snapshot, _) => MedCategory.fromJson(snapshot),
        toFirestore: (category, _) => category.toJson(),
      );

  addCategory(MedCategory category) async {
    await _firestore.collection('categories').add(category.toJson());
  }

  Query<MedCompany> getCompaniesQuery() => _firestore.collection('companies').orderBy('name').withConverter(
        fromFirestore: (snapshot, _) => MedCompany.fromJson(snapshot),
        toFirestore: (company, _) => company.toJson(),
      );

  addCompany(MedCompany company) async {
    await _firestore.collection('companies').add({
      'name': company.name,
    });
  }

  addMed(Med med) async {
    await _firestore.collection('meds').add(med.toJson());
  }

  addToStorage(Med med, int count) async {
    final medRef = _firestore.collection('meds').doc(med.id);

    final oldItem = await _firestore
        .collection('storage')
        .withConverter(
          fromFirestore: (snapshot, _) => StorageItem.fromJson(snapshot),
          toFirestore: (storageItem, _) => storageItem.toJson(),
        )
        .where('med', isEqualTo: medRef)
        .limit(1)
        .get();

    if (oldItem.size == 0) {
      await _firestore.collection('storage').add({
        'med': medRef,
        'count': count,
      });
    } else {
      final storageItem = oldItem.docs[0].data();

      await _firestore.collection('storage').doc(oldItem.docs[0].id).update({
        'count': storageItem.count + count,
      });
    }
  }
}
