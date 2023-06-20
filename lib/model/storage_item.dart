import 'package:cloud_firestore/cloud_firestore.dart';

class StorageItem {
  final String id;
  final DocumentReference medRef;
  final int count;
  final DateTime expirationDate;

  StorageItem({
    required this.id,
    required this.medRef,
    required this.count,
    required this.expirationDate,
  });

  static FromFirestore<StorageItem> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return StorageItem(
      id: snapshot.id,
      medRef: data['med'] as DocumentReference,
      count: data['count'] as int,
      expirationDate: (data['expirationDate'] as Timestamp).toDate(),
    );
  };

  static ToFirestore<StorageItem> toFirestore = (storageItem, _) => storageItem.toJson();

  Map<String, dynamic> toJson() => {
        'med': medRef,
        'count': count,
        'expirationDate': Timestamp.fromDate(expirationDate),
      };
}
