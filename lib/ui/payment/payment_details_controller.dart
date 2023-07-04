import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:pharmacy/model/payment_item.dart';
import 'package:provider/provider.dart';

class PaymentDetailsController extends ChangeNotifier {
  final Repository _repository;
  final Payment payment;

  bool get isAdmin => _repository.isAdmin;

  PaymentDetailsController(
    BuildContext context, {
    required this.payment,
  }) : _repository = context.read();

  Query<PaymentItem> getPaymentItems() => payment.items;

  Future printReceipt() => _repository.printPayment(payment);
}
