import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy/model/user.dart';
import 'package:pharmacy/utils/constants.dart';
import 'package:pharmacy/widget/custom_firestore_listview.dart';
import 'package:provider/provider.dart';

import 'payments_controller.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PaymentsController(context),
      builder: (context, child) {
        return _PaymentsPage();
      },
    );
  }
}

class _PaymentsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<_PaymentsPage> {
  late final controller = context.watch<PaymentsController>();

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(top: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: CustomFirestoreListView(
        query: controller.getPaymentsQuery(),
        padding: viewPadding + const EdgeInsets.all(16),
        itemBuilder: (context, doc) {
          final payment = doc.data();

          return Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(children: [
                      const Text(
                        'Seller : ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      StreamBuilder(
                        stream: payment.sellerRef
                            .withConverter(
                              fromFirestore: User.fromFirestore,
                              toFirestore: User.toFirestore,
                            )
                            .snapshots(),
                        builder: (context, snapshot) {
                          Widget title;

                          if (snapshot.hasData && snapshot.data!.data() != null) {
                            final user = snapshot.data!.data()!;

                            title = Text(user.name);
                          } else {
                            title = const SizedBox();
                          }

                          return title;
                        },
                      ),
                    ]),
                    TableRow(
                      children: [
                        const Text(
                          'Buyer : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(payment.buyerName),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          'Date : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(DateFormat('dd-MM-yyyy hh:mm a').format(payment.date)),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          'Total : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder(
                          future: payment.items.count().get(),
                          builder: (context, snapshot) {
                            Widget title;

                            if (snapshot.hasData) {
                              final count = snapshot.data!.count;

                              title = Text('${getCurrencyFormat().format(payment.total)} ($count) items');
                            } else {
                              title = const SizedBox();
                            }

                            return title;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
