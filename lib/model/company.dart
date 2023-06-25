import 'package:cloud_firestore/cloud_firestore.dart';

class MedCompany {
  final String id;
  final String name;
  final int quality;

  MedCompany({
    required this.id,
    required this.name,
    required this.quality,
  });

  static FromFirestore<MedCompany> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return MedCompany(
      id: snapshot.id,
      name: data['name'] ?? '',
      quality: data['quality'] ?? 1,
    );
  };

  static ToFirestore<MedCompany> toFirestore = (company, _) => company.toJson();

  Map<String, dynamic> toJson() => {
        'name': name,
        'quality': quality,
      };
}
