import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharmacy/model/med.dart';

class PaymentItem {
  final DocumentReference<Med> medRef;
  final int amount;
  final double individualPrice;

  PaymentItem({
    required this.medRef,
    required this.amount,
    required this.individualPrice,
  });

  PaymentItem copyWith({
    DocumentReference<Med>? medRef,
    int? amount,
    double? individualPrice,
  }) =>
      PaymentItem(
        medRef: medRef ?? this.medRef,
        amount: amount ?? this.amount,
        individualPrice: individualPrice ?? this.individualPrice,
      );

  @override
  bool operator ==(Object other) {
    if (other is PaymentItem) {
      return medRef.id == other.medRef.id;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => medRef.id.hashCode >> amount.hashCode >> individualPrice.hashCode;

  Map<String, dynamic> toJson() => {
        'med': medRef,
        'amount': amount,
        'price': individualPrice,
      };
}
