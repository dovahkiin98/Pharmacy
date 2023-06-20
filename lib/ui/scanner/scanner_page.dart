import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  final bool exitOnScan;

  const ScannerPage({
    required this.exitOnScan,
    super.key,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController scannerController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: MobileScanner(
        controller: scannerController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
          }

          if (barcodes.isNotEmpty) {
            final barcode = barcodes[0];

            if (barcode.rawValue != null && widget.exitOnScan) {
              scannerController.stop();
              Navigator.pop(context, barcodes[0].displayValue);
            }
          }
        },
      ),
    );
  }
}
