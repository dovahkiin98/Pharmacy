import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pharmacy/model/med.dart';
import 'package:pharmacy/ui/home/storage/widget/medication_selector.dart';
import 'package:pharmacy/ui/transaction/transaction_controller.dart';
import 'package:pharmacy/utils/constants.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionController(context),
      builder: (context, child) {
        return _TransactionPage();
      },
    );
  }
}

class _TransactionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<_TransactionPage> {
  static const SCANNER_DELAY = Duration(seconds: 3);

  final buyerNameTextController = TextEditingController();
  final draggableController = DraggableScrollableController();
  final scannerController = MobileScannerController();

  final player = AudioPlayer();

  final currencyFormat = getCurrencyFormat();

  bool scannedRecently = false;

  late final controller = context.watch<TransactionController>();

  @override
  void initState() {
    super.initState();

    player.loadManually('assets/mp3/beep.mp3');
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context).copyWith(top: 0);

    return WillPopScope(
      onWillPop: () async {
        if (controller.items.isEmpty) {
          return true;
        } else {
          _showPopDialog();
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction'),
          actions: [
            if (controller.items.isNotEmpty)
              Tooltip(
                message: 'Complete Transaction',
                child: TextButton(
                  onPressed: () {
                    _showBuyerDialog();
                  },
                  child: const Text('Complete'),
                ),
              ),
          ],
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 56),
        //   child: FloatingActionButton.extended(
        //     onPressed: () {},
        //     label: const Text('Complete Transaction'),
        //   ),
        // ),
        body: Padding(
          padding: viewPadding,
          child: Stack(
            children: [
              MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;

                  if (barcodes.isNotEmpty && !scannedRecently) {
                    final barcode = barcodes[0];

                    if (barcode.rawValue != null && barcode.format == BarcodeFormat.ean13) {
                      player.play();
                      // player.play(AssetSource('assets/mp3/beep.mp3'));

                      controller.addByBarcode(barcode.rawValue!).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(error.toString()),
                        ));
                      });

                      scannedRecently = true;
                      Future.delayed(SCANNER_DELAY).then((value) {
                        scannedRecently = false;
                      });
                    }
                  }
                },
              ),
              LayoutBuilder(builder: (context, constraints) {
                heightToPercent(double height) {
                  return height / constraints.maxHeight;
                }

                return DraggableScrollableSheet(
                  initialChildSize: heightToPercent(60),
                  maxChildSize: 1,
                  controller: draggableController,
                  minChildSize: heightToPercent(60),
                  snap: true,
                  snapSizes: [
                    heightToPercent(60),
                    heightToPercent(240),
                    1,
                  ],
                  builder: (context, scrollController) {
                    final itemCount = controller.items.fold<int>(0, (previousValue, element) {
                      return previousValue + element.amount;
                    });

                    return Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: ListView(
                        controller: scrollController,
                        children: [
                          const Divider(height: 4),
                          ListTile(
                            title: Text('$itemCount items'),
                            trailing: Text(
                              currencyFormat.format(controller.items.fold<double>(0, (previousValue, element) {
                                return previousValue + (element.individualPrice * element.amount);
                              })),
                            ),
                          ),
                          const Divider(height: 4),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const MedicationSelector(),
                                ).then((value) {
                                  if (value is Med) {
                                    _addMed(value.reference!);
                                  }
                                });
                              },
                              child: const Text('Add Manually'),
                            ),
                          ),
                          ...controller.items.map(
                            (e) => StreamBuilder(
                              stream: e.medRef.snapshots(),
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
                                  subtitle: Text(currencyFormat.format(e.individualPrice)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _addMed(e.medRef);
                                        },
                                        tooltip: 'Add',
                                        icon: const Icon(Icons.add),
                                      ),
                                      Text(e.amount.toString()),
                                      IconButton(
                                        onPressed: () {
                                          controller.removeMed(e.medRef).onError((error, stackTrace) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(error.toString()),
                                            ));
                                          });
                                        },
                                        tooltip: 'Remove',
                                        icon: const Icon(Icons.remove),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    scannerController.dispose();
    player.dispose();
  }

  void _showBuyerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Transaction'),
          content: TextField(
            controller: buyerNameTextController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Buyer Name (Optional)',
              labelText: 'Buyer Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(buyerNameTextController.text.trim());
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value is String) {
        controller.createPayment(value).then(
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Transaction Complete!'),
            ));

            Navigator.of(context).pop();
          },
          onError: (error, stacktrace) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.toString()),
            ));
          },
        );
      }
    });
  }

  void _addMed(DocumentReference<Med> med) {
    controller.addMed(med).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
    });
  }

  void _showPopDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel transaction'),
        content: const Text('Are you sure you want to cancel this transaction'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    ).then((value) {
      if (value == true) {
        Navigator.of(context).pop();
      }
    });
  }
}
