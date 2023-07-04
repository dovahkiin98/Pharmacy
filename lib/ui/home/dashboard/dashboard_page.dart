import 'package:flutter/material.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/ui/home/dashboard/dashboard_controller.dart';
import 'package:pharmacy/ui/home/storage/widget/storage_list_item.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardController(context),
      builder: (context, child) {
        return _DashboardPage();
      },
    );
  }
}

class _DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  late final controller = context.watch<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(top: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: DrawerButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: ListView(
        padding: viewPadding + const EdgeInsets.all(16) + const EdgeInsets.only(bottom: 64),
        children: [
          StreamBuilder(
            stream: controller.getExpired(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final expiredMeds = snapshot.data!.docs;

                if (expiredMeds.isNotEmpty) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'These storage items have expired',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ...expiredMeds.map((e) {
                            final storageItem = e.data();

                            return StorageListItem(storageItem);
                          }),
                        ],
                      ),
                    ),
                  );
                }
              }

              return const SizedBox.shrink();
            },
          ),
          StreamBuilder(
            stream: controller.getSoonToExpire(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final soonToExpireMeds = snapshot.data!.docs;

                if (soonToExpireMeds.isNotEmpty) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'These storage items will expire within 5 days',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ...soonToExpireMeds.map((e) {
                            final storageItem = e.data();

                            return StorageListItem(storageItem);
                          }),
                        ],
                      ),
                    ),
                  );
                }
              }

              return const SizedBox.shrink();
            },
          ),
          StreamBuilder(
            stream: controller.getAlmostOutOfStock(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final almostOutOfStockMeds = snapshot.data!;

                if (almostOutOfStockMeds.isNotEmpty) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Less than 5 of these items remain in storage',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ...almostOutOfStockMeds.map((e) {
                            final storageItem = e;

                            return StorageListItem(
                              storageItem,
                              showDate: false,
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pushNamed(Routes.TRANSACTION);
        },
        label: const Text('Start Transaction'),
        icon: const Icon(Icons.attach_money),
      ),
    );
  }
}
