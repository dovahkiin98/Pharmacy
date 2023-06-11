import 'package:cloud_firestore/cloud_firestore.dart';

class MedCompany {
  final String id;
  final String name;

  MedCompany({
    required this.id,
    required this.name,
  });

  factory MedCompany.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return MedCompany(
      id: snapshot.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
