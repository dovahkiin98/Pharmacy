import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final double total;
  final DateTime date;
  final String buyerName;
  final DocumentReference sellerRef;
  final CollectionReference items;

  Payment({
    required this.id,
    required this.total,
    required this.date,
    required this.buyerName,
    required this.sellerRef,
    required this.items,
  });

  static FromFirestore<Payment> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Payment(
      id: snapshot.id,
      total: data['total'],
      date: (data['date'] as Timestamp).toDate(),
      buyerName: data['buyer'],
      sellerRef: data['seller'] as DocumentReference,
      items: snapshot.reference.collection('items'),
    );
  };

  static ToFirestore<Payment> toFirestore = (med, _) => med.toJson();

  Map<String, dynamic> toJson() => {
        'id': id,
        'total': total,
        'date': Timestamp.fromDate(date),
        'buyer': buyerName,
        'seller': sellerRef,
        'items': items,
      };
}
