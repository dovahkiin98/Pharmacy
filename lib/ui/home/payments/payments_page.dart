import 'package:flutter/material.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/model/payment.dart';
import 'package:pharmacy/ui/home/payments/widget/payment_list_item.dart';
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
        leading: DrawerButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: CustomFirestoreListView(
        query: controller.getPaymentsQuery(),
        padding: viewPadding + const EdgeInsets.all(8),
        itemBuilder: (context, doc) {
          final payment = doc.data();

          return PaymentListItem(
            payment,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pushNamed(
                Routes.PAYMENT_DETAILS,
                arguments: {'payment': payment},
              );
            },
            onLongPress: () {
              _showSheet(payment);
            },
          );
        },
      ),
    );
  }

  void _showSheet(Payment payment) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewPaddingOf(context) +
              const EdgeInsets.only(
                bottom: 16,
                top: 32,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('View Details'),
                leading: const Icon(Icons.payment),
                onTap: () {
                  Navigator.pop(context, 0);
                },
              ),
              ListTile(
                title: const Text('Print Receipt'),
                leading: const Icon(Icons.print),
                onTap: () {
                  Navigator.pop(context, 1);
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value == 0) {
        Navigator.of(context, rootNavigator: true).pushNamed(
          Routes.PAYMENT_DETAILS,
          arguments: {'payment': payment},
        );
      } else if (value == 1) {
        controller.printReceipt(payment);
      }
    });
  }
}
