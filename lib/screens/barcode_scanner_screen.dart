import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController cameraController;
  late CustomTheme customTheme;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    cameraController = MobileScannerController(formats: [
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code39,
      BarcodeFormat.code128,
      BarcodeFormat.code93,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 0.0),
                )
              ],
              color: customTheme.Primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          elevation: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) {
              if (barcode.rawValue == null) {
                print('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue!;
                Navigator.pop(context, code);
              }
            }),
        floatingActionButton: FloatingActionButton(
          child: ValueListenableBuilder(
            valueListenable: cameraController.torchState,
            builder: (context, state, child) {
              switch (state as TorchState) {
                case TorchState.off:
                  return const Icon(Icons.flash_off, color: Colors.white);
                case TorchState.on:
                  return const Icon(Icons.flash_on, color: Colors.white);
              }
            },
          ),
          onPressed: () => cameraController.toggleTorch(),
          backgroundColor: customTheme.Primary,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      );
    });
  }
}
