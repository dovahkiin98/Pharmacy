import 'package:cloud_firestore/cloud_firestore.dart';

class Med {
  final String id;
  final String name;
  final String description;
  final DocumentReference? categoryRef;
  final DocumentReference? companyRef;

  Med({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryRef,
    required this.companyRef,
  });

  Med.empty()
      : this(
          id: '',
          name: '',
          description: '',
          categoryRef: null,
          companyRef: null,
        );

  factory Med.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Med(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryRef: data['category'] as DocumentReference?,
      companyRef: data['company'] as DocumentReference?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': categoryRef,
        'company': companyRef,
      };

  Med copyWith({
    String? name,
    String? description,
    DocumentReference? categoryRef,
    DocumentReference? companyRef,
  }) =>
      Med(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        categoryRef: categoryRef ?? this.categoryRef,
        companyRef: companyRef ?? this.companyRef,
      );
}
