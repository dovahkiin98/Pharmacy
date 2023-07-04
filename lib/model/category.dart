import 'package:cloud_firestore/cloud_firestore.dart';

class MedCategory {
  final DocumentReference<MedCategory>? reference;
  final String id;
  final String name;
  final String description;

  MedCategory({
    this.reference,
    required this.id,
    required this.name,
    required this.description,
  });

  static FromFirestore<MedCategory> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return MedCategory(
      reference: snapshot.reference.withConverter(
        fromFirestore: fromFirestore,
        toFirestore: toFirestore,
      ),
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    );
  };

  static ToFirestore<MedCategory> toFirestore = (category, _) => category.toJson();

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
