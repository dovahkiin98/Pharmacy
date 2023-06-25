import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  final scannerController = MobileScannerController();
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    player.setAsset('assets/mp3/beep.mp3');
  }

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

          if (barcodes.isNotEmpty) {
            final barcode = barcodes[0];

            if (barcode.rawValue != null && barcode.format == BarcodeFormat.ean13) {
              scannerController.stop();

              player.play();

              if (widget.exitOnScan) {
                Navigator.pop(context, barcodes[0].displayValue);
              } else {
                Future.delayed(const Duration(seconds: 5)).then((value) {
                  scannerController.start();
                });
              }
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    scannerController.dispose();
    player.dispose();
  }
}
