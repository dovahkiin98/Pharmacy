import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/model/category.dart';
import 'package:pharmacy/model/company.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:pharmacy/model/payment_item.dart';
import 'package:pharmacy/model/storage_item.dart';
import 'package:pharmacy/model/user.dart';
import 'package:pharmacy/notifications.dart';
import 'package:pharmacy/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository with ChangeNotifier {
  static const TIMEOUT = Duration(seconds: 8);

  /// Firebase Emulator IP (Local IP)
  static const FIREBASE_IP = "192.168.1.100";

  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  final _flutterNotifications = FlutterLocalNotificationsPlugin();

  final SharedPreferences _prefs;
  Timer? _storageCheckJob;

  Repository(this._prefs) {
    _startStorageCheckJob();
  }

  String? get userId => _prefs.getString('userId');

  bool get isUserLoggedIn => _prefs.getString('userId') != null;

  bool get isAdmin => _prefs.getBool('isAdmin') ?? false;

  String get ip => _prefs.getString('ip') ?? FIREBASE_IP;

  void updateIP(String ip) async {
    await _prefs.setString('ip', ip);

    // Initializing Firestore with the Firebase Emulator IP.
    FirebaseFirestore.instance.settings = Settings(
      host: '$ip:8080',
      sslEnabled: false,
      persistenceEnabled: true,
    );

    // Initializing Firebase Auth with the Firebase Emulator IP.
    await FirebaseAuth.instance.useAuthEmulator(ip, 9099);
  }

  Future login(String email, String password) async {
    final userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(TIMEOUT);

    final userData = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    final isAdmin = userData.data()!['admin'] ?? false;

    await _prefs.setString('userId', userData.id);
    await _prefs.setBool('isAdmin', isAdmin);
  }

  Future logout() async {
    await _firebaseAuth.signOut();

    await _prefs.remove('userId');
    await _prefs.remove('isAdmin');
  }

  CollectionReference<Med> getMedsQuery() => _firestore.collection('meds').withConverter(
        fromFirestore: Med.fromFirestore,
        toFirestore: Med.toFirestore,
      );

  Future deleteMed(Med med) async {
    await _firestore.collection('meds').doc(med.id).delete();
  }

  DocumentReference<Med> getMedItemDoc(String id) => _firestore.collection('meds').doc(id).withConverter(
        fromFirestore: Med.fromFirestore,
        toFirestore: Med.toFirestore,
      );

  DocumentReference<PharmacyUser> getUserItemDoc(String id) => _firestore.collection('users').doc(id).withConverter(
        fromFirestore: PharmacyUser.fromFirestore,
        toFirestore: PharmacyUser.toFirestore,
      );

  CollectionReference<MedCategory> getCategoriesQuery() => _firestore.collection('categories').withConverter(
        fromFirestore: MedCategory.fromFirestore,
        toFirestore: MedCategory.toFirestore,
      );

  addCategory(MedCategory category) async {
    await _firestore.collection('categories').add(category.toJson()).timeout(TIMEOUT);
  }

  CollectionReference<MedCompany> getCompaniesQuery() => _firestore.collection('companies').withConverter(
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

  Query<StorageItem> getStorageQuery() {
    final query = _firestore
        .collection('storage')
        .withConverter(
          fromFirestore: StorageItem.fromFirestore,
          toFirestore: StorageItem.toFirestore,
        )
        .where(
          'user',
          isEqualTo: !isAdmin ? _firestore.collection('users').doc(userId!) : null,
        );

    return query;
  }

  Future addToStorage(
    Med med,
    int amount,
    Timestamp expirationDate,
  ) async {
    await _firestore.collection('storage').add({
      'med': _firestore.collection('meds').doc(med.id),
      'amount': amount,
      'expirationDate': expirationDate,
      'user': _firestore.collection('users').doc(userId!),
    }).timeout(TIMEOUT);
  }

  Future removeFromStorage(StorageItem storageItem) async {
    await _firestore.collection('storage').doc(storageItem.id).delete();
  }

  Stream<QuerySnapshot<StorageItem>> getSoonToExpireQuery() => getStorageQuery()
      .where(
        'expirationDate',
        isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        isGreaterThan: Timestamp.now(),
      )
      .snapshots();

  Stream<QuerySnapshot<StorageItem>> getExpiredQuery() => getStorageQuery()
      .where(
        'expirationDate',
        isLessThanOrEqualTo: Timestamp.now(),
      )
      .snapshots();

  Stream<List<StorageItem>> getAlmostOutOfStock() => getStorageQuery().snapshots().map(
        (event) {
          final pharmacies = <DocumentReference<PharmacyUser>, Map<DocumentReference<Med>, int>>{};

          for (var element in event.docs) {
            final storageItem = element.data();

            final pharmacy = pharmacies[storageItem.userRef] ?? {};

            pharmacy[storageItem.medRef] = (pharmacy[storageItem.medRef] ?? 0) + storageItem.amount;

            pharmacies[storageItem.userRef] = pharmacy;
          }

          final filteredList = <StorageItem>[];

          for (var MapEntry(key: pharmacy, value: map) in pharmacies.entries) {
            for (var MapEntry(:key, value: amount) in map.entries) {
              if (amount < 5) {
                filteredList.add(StorageItem(
                  id: '',
                  amount: amount,
                  medRef: key,
                  userRef: pharmacy,
                  expirationDate: DateTime.now(),
                ));
              }
            }
          }

          return filteredList;
        },
      );

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
      final med = await getMedItemDoc(element.data().medRef.id).get();
      final user = await getUserItemDoc(element.data().userRef.id).get();

      await _flutterNotifications.show(
        element.id.hashCode,
        'Storage Item Expired',
        [
          'Item',
          ' ${med.data()!.name} ',
          if (isAdmin) 'in Pharmacy "${user.data()!.name}" ',
          'has expired',
        ].join(),
        androidAlertsChannel,
      );
    }

    for (var element in soonToExpireMed.docs) {
      final med = await getMedItemDoc(element.data().medRef.id).get();
      final user = await getUserItemDoc(element.data().userRef.id).get();

      await _flutterNotifications.show(
        element.id.hashCode,
        'Storage Item Expiring Soon',
        [
          'Item',
          ' ${med.data()!.name} ',
          if (isAdmin) 'in Pharmacy "${user.data()!.name}" ',
          'will expire in ',
          element.data().expirationDate.difference(DateTime.now()).inDays,
          ' days',
        ].join(),
        androidAlertsChannel,
      );
    }

    for (var element in almostOutOfStock) {
      final med = await getMedItemDoc(element.medRef.id).get();
      final user = await getUserItemDoc(element.userRef.id).get();

      await _flutterNotifications.show(
        med.id.hashCode,
        'Storage Item almost out of stock',
        [
          'Only',
          ' ${element.amount} ',
          'of item',
          ' ${med.data()!.name} ',
          if (isAdmin) 'in Pharmacy "${user.data()!.name}" ',
          'remain',
        ].join(),
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
        (previousValue, element) => previousValue + (element.totalPrice),
      ),
    }).timeout(TIMEOUT);

    final itemsCollection = newDoc.collection('items');

    for (var element in items) {
      await itemsCollection.add(element.toJson());

      final storageItems = (await getStorageQuery()
              .where(
                'med',
                isEqualTo: element.medRef,
              )
              .orderBy('expirationDate')
              .get())
          .docs
        ..sort(
          (a, b) => a.data().expirationDate.compareTo(b.data().expirationDate),
        );

      var amount = element.amount;

      for (var doc in storageItems) {
        final storageItem = doc.data();

        if (amount >= storageItem.amount) {
          amount -= storageItem.amount;
          await doc.reference.delete();
        } else {
          final newAmount = storageItem.amount - amount;

          await doc.reference.update({'amount': newAmount});
          break;
        }
      }
    }

    final payment = await getPaymentsQuery().doc(newDoc.id).get();

    printPayment(payment.data()!);
  }

  Future printPayment(Payment payment) async {
    final (res, printer) = await _connectToPrinter(
      '192.168.0.123',
      port: 9100,
    );

    if (res == PosPrintResult.success) {
      final items = await payment.items
          .withConverter(
            fromFirestore: PaymentItem.fromFirestore,
            toFirestore: PaymentItem.toFirestore,
          )
          .get();

      printer.text(
        'Pharmacy',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      // print header
      printer.hr();

      // print items header
      printer.row([
        PosColumn(text: 'Qty', width: 1),
        PosColumn(text: 'Item', width: 7),
        PosColumn(
          text: 'Price',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'Total',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      for (var item in items.docs) {
        final paymentItem = item.data();
        final med = (await paymentItem.medRef.get()).data()!;

        // print item amount, item name, price of each item, and total price of item
        printer.row([
          PosColumn(text: paymentItem.amount.toString(), width: 1),
          PosColumn(text: med.name, width: 7),
          PosColumn(
            text: paymentItem.individualPrice.toStringAsFixed(0),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (paymentItem.totalPrice).toStringAsFixed(0),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      // print header
      printer.hr();

      // print total amount
      printer.row([
        PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: const PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: getCurrencyFormat().format(payment.total),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      ]);
      printer.hr(ch: '=', linesAfter: 1);

      // skip 2 lines
      printer.feed(2);
      printer.text(
        'Thank You!',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );

      final formatter = DateFormat('MM/dd/yyyy hh:mm a');
      final String timestamp = formatter.format(payment.date);
      // print date
      printer.text(
        timestamp,
        styles: const PosStyles(align: PosAlign.center),
      );

      // skip 2 lines
      printer.feed(2);
      // cut the receipt
      printer.cut();

      printer.disconnect();
    }
  }

  Future<(PosPrintResult, NetworkPrinter)> _connectToPrinter(
    String ip, {
    int port = 91000,
  }) async {
    const paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final res = await printer.connect(ip, port: port);

    return (res, printer);
  }

  CollectionReference<Payment> getPaymentsQuery() => _firestore.collection('payments').withConverter(
        fromFirestore: Payment.fromFirestore,
        toFirestore: Payment.toFirestore,
      );

  @override
  void dispose() {
    super.dispose();

    _storageCheckJob?.cancel();
  }
}
