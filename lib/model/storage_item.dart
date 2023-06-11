import 'package:cloud_firestore/cloud_firestore.dart';

class StorageItem {
  final String id;
  final DocumentReference medRef;
  final int count;

  StorageItem({
    required this.id,
    required this.medRef,
    required this.count,
  });

  factory StorageItem.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return StorageItem(
      id: snapshot.id,
      medRef: data['med'] as DocumentReference,
      count: data['count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'med': medRef,
        'count': count,
      };
}
