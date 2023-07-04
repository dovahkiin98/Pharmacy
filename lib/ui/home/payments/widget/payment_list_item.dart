import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:pharmacy/model/user.dart';
import 'package:pharmacy/utils/constants.dart';
import 'package:provider/provider.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PaymentListItem(
    this.payment, {
    super.key,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(1),
            },
            children: [
              if (repo.isAdmin)
                TableRow(children: [
                  const Text(
                    'Seller : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  StreamBuilder(
                    stream: payment.sellerRef
                        .withConverter(
                          fromFirestore: PharmacyUser.fromFirestore,
                          toFirestore: PharmacyUser.toFirestore,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.data() != null) {
                        final user = snapshot.data!.data()!;

                        return Text(
                          user.name,
                          style: const TextStyle(fontSize: 16),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ]),
              TableRow(
                children: [
                  const Text(
                    'Buyer : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    payment.buyerName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    'Date : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy hh:mm a').format(payment.date),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    'Total : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  FutureBuilder(
                    future: payment.items.get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final count = snapshot.data!.docs.fold<int>(
                          0,
                          (previousValue, element) => previousValue + element.data().amount,
                        );

                        return Text(
                          '${getCurrencyFormat().format(payment.total)} ($count) items',
                          style: const TextStyle(fontSize: 16),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
