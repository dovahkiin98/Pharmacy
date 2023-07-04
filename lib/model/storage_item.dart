import 'package:cloud_firestore/cloud_firestore.dart';

import 'med.dart';
import 'user.dart';

class StorageItem {
  final String id;
  final DocumentReference<Med> medRef;
  final DocumentReference<PharmacyUser> userRef;
  final int amount;
  final DateTime expirationDate;

  StorageItem({
    required this.id,
    required this.medRef,
    required this.userRef,
    required this.amount,
    required this.expirationDate,
  });

  static FromFirestore<StorageItem> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return StorageItem(
      id: snapshot.id,
      medRef: (data['med'] as DocumentReference).withConverter(
        fromFirestore: Med.fromFirestore,
        toFirestore: Med.toFirestore,
      ),
      userRef: (data['user'] as DocumentReference).withConverter(
        fromFirestore: PharmacyUser.fromFirestore,
        toFirestore: PharmacyUser.toFirestore,
      ),
      amount: (data['amount'] as int?) ?? (data['count'] as int?) ?? 1,
      expirationDate: (data['expirationDate'] as Timestamp).toDate(),
    );
  };

  static ToFirestore<StorageItem> toFirestore = (storageItem, _) => storageItem.toJson();

  Map<String, dynamic> toJson() => {
        'med': medRef,
        'user': userRef,
        'amount': amount,
        'expirationDate': Timestamp.fromDate(expirationDate),
      };
}
