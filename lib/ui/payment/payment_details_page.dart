import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:pharmacy/model/user.dart';
import 'package:pharmacy/ui/payment/payment_details_controller.dart';
import 'package:pharmacy/utils/constants.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:provider/provider.dart';

class PaymentDetailsPage extends StatelessWidget {
  final Payment payment;

  const PaymentDetailsPage({
    required this.payment,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PaymentDetailsController(context, payment: payment),
      builder: (context, child) {
        return _PaymentDetailsPage();
      },
    );
  }
}

class _PaymentDetailsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<_PaymentDetailsPage> {
  late final controller = context.watch<PaymentDetailsController>();
  final currencyFormat = getCurrencyFormat();

  @override
  Widget build(BuildContext context) {
    final payment = controller.payment;
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(top: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        actions: [
          IconButton(
            onPressed: () {
              controller.printReceipt();
            },
            tooltip: 'Print Receipt',
            icon: const Icon(Icons.print),
          )
        ],
      ),
      body: ListView(
        padding: viewPadding + const EdgeInsets.all(16),
        children: [
          const Text(
            'Seller : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
                  style: const TextStyle(fontSize: 20),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Buyer : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            payment.buyerName,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Date : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            DateFormat('dd-MM-yyyy hh:mm a').format(payment.date),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Total : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
                  style: const TextStyle(fontSize: 20),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Items : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          CustomFirestoreListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            query: controller.getPaymentItems(),
            itemBuilder: (context, doc) {
              final paymentItem = doc.data();

              return StreamBuilder(
                stream: paymentItem.medRef.snapshots(),
                builder: (context, snapshot) {
                  Widget title;

                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    final med = snapshot.data!.data()!;

                    title = Text(med.name);
                  } else {
                    title = const SizedBox();
                  }

                  return ListTile(
                    title: title,
                    subtitle: Text(currencyFormat.format(paymentItem.individualPrice)),
                    contentPadding: EdgeInsets.zero,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(paymentItem.amount.toString()),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
