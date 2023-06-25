import 'package:flutter/material.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:pharmacy/widget/error_view.dart';
import 'package:provider/provider.dart';

import '../database_controller.dart';
import 'med_item.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DatabaseController>();

    return Scaffold(
      body: StreamBuilder(
        stream: controller.getMedsQuery().orderBy('company').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!);
          } else if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final meds = snapshot.data!.docs;

            return ListView.builder(
              itemBuilder: (context, i) {
                final currentMed = meds[i].data();
                final previousMed = i == 0 ? null : meds[i - 1].data();

                final isDifferentCompany =
                    previousMed == null || currentMed.companyRef!.id != previousMed.companyRef!.id;

                final medListTile = MedListTile(
                  currentMed,
                  onTap: () {
                    _showSheet(context, currentMed);
                  },
                );

                if (isDifferentCompany) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder(
                        stream: controller.getCompanyItemDoc(currentMed.companyRef!.id),
                        builder: (context, snapshot) {
                          if (snapshot.data?.data() != null) {
                            final company = snapshot.data!.data()!;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                company.name,
                                style: TextStyle(color: getQualityColor(company.quality)),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      medListTile,
                    ],
                  );
                } else {
                  return medListTile;
                }
              },
              itemCount: meds.length,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(Routes.ADD_MED);
        },
        label: const Text('Add Medication'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showSheet(
    BuildContext context,
    Med med,
  ) {
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
                title: const Text('Edit'),
                leading: const Icon(Icons.edit),
                onTap: () {
                  Navigator.pop(context, 0);
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    Routes.ADD_MED,
                    arguments: {'med': med},
                  );
                },
              ),
              ListTile(
                title: const Text('Delete'),
                leading: const Icon(Icons.delete),
                onTap: () {
                  Navigator.pop(context, 1);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
