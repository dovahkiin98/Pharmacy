import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharmacy/model/payment_item.dart';
import 'package:pharmacy/model/user.dart';

class Payment {
  final String id;
  final double total;
  final DateTime date;
  final String buyerName;
  final DocumentReference<PharmacyUser> sellerRef;
  final CollectionReference<PaymentItem> items;

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
      total: (data['total'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      buyerName: data['buyer'],
      sellerRef: (data['seller'] as DocumentReference).withConverter(
        fromFirestore: PharmacyUser.fromFirestore,
        toFirestore: PharmacyUser.toFirestore,
      ),
      items: snapshot.reference.collection('items').withConverter(
            fromFirestore: PaymentItem.fromFirestore,
            toFirestore: PaymentItem.toFirestore,
          ),
    );
  };

  static ToFirestore<Payment> toFirestore = (payment, _) => payment.toJson();

  Map<String, dynamic> toJson() => {
        'id': id,
        'total': total,
        'date': Timestamp.fromDate(date),
        'buyer': buyerName,
        'seller': sellerRef,
        'items': items,
      };
}
