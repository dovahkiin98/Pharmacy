import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:provider/provider.dart';

class PaymentsController extends ChangeNotifier {
  final Repository _repository;

  PaymentsController(BuildContext context) : _repository = context.read();

  Query<Payment> getPaymentsQuery() => _repository.getPaymentsQuery();
}
