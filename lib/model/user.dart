import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyUser {
  final String id;
  final String name;

  PharmacyUser({
    required this.id,
    required this.name,
  });

  static FromFirestore<PharmacyUser> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return PharmacyUser(
      id: snapshot.id,
      name: data['name'] ?? '',
    );
  };

  static ToFirestore<PharmacyUser> toFirestore = (category, _) => category.toJson();

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
