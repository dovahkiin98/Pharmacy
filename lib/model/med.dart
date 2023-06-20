import 'package:cloud_firestore/cloud_firestore.dart';

class Med {
  final String id;
  final String name;
  final double price;
  final String description;
  final String barcode;
  final DocumentReference? categoryRef;
  final DocumentReference? companyRef;

  Med({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.barcode,
    required this.categoryRef,
    required this.companyRef,
  });

  Med.empty()
      : this(
          id: '',
          name: '',
          description: '',
          price: 0.0,
          barcode: '',
          categoryRef: null,
          companyRef: null,
        );

  factory Med.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Med(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0,
      barcode: data['barcode'] ?? '',
      categoryRef: data['category'] as DocumentReference?,
      companyRef: data['company'] as DocumentReference?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
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
