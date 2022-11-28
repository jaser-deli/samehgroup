import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return ReaderWidget(
      onScan: (result) async {
        print(result);
        // Navigator.pop(context, result);
      },
    );
  }
}
