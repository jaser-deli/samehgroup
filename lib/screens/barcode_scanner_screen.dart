import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReaderWidget(
        onScan: (value) {
          showMessage(context, 'Scanned: ${value.textString ?? ''}');
        },
      ),
    );
  }

  showMessage(BuildContext context, String message) {
    debugPrint(message);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
