import 'package:cloud_firestore/cloud_firestore.dart';

class Med {
  final DocumentReference? reference;
  final String id;
  final String name;
  final double price;
  final String description;
  final String barcode;
  final DocumentReference? categoryRef;
  final DocumentReference? companyRef;

  Med({
    this.reference,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.barcode,
    this.categoryRef,
    this.companyRef,
  });

  Med.empty()
      : this(
          id: '',
          name: '',
          description: '',
          price: 0.0,
          barcode: '',
        );

  static FromFirestore<Med> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Med(
      reference: snapshot.reference,
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0,
      barcode: data['barcode'] ?? '',
      categoryRef: data['category'] as DocumentReference?,
      companyRef: data['company'] as DocumentReference?,
    );
  };

  static ToFirestore<Med> toFirestore = (med, _) => med.toJson();

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'barcode': barcode,
        'category': categoryRef,
        'company': companyRef,
      };

  Med copyWith({
    String? name,
    String? description,
    double? price,
    String? barcode,
    DocumentReference? categoryRef,
    DocumentReference? companyRef,
  }) =>
      Med(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        barcode: barcode ?? this.barcode,
        categoryRef: categoryRef ?? this.categoryRef,
        companyRef: companyRef ?? this.companyRef,
      );
}
