import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class JoinPage extends StatelessWidget {
  const JoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join")),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
        ),
        onDetect: (capture) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("You scanned this qr code:"),
                  content: Text(capture.barcodes.first.url!.url),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text("Ok"),
                    ),
                  ],
                ),
          );
          HapticFeedback.vibrate();
        },
      ),
    );
  }
}
