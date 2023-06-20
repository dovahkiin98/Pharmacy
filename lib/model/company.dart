import 'package:cloud_firestore/cloud_firestore.dart';

class MedCompany {
  final String id;
  final String name;

  MedCompany({
    required this.id,
    required this.name,
  });

  static FromFirestore<MedCompany> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return MedCompany(
      id: snapshot.id,
      name: data['name'] ?? '',
    );
  };

  static ToFirestore<MedCompany> toFirestore = (company, _) => company.toJson();

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
