import 'package:cloud_firestore/cloud_firestore.dart';

class MedCategory {
  final String id;
  final String name;
  final String description;

  MedCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory MedCategory.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return MedCategory(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
