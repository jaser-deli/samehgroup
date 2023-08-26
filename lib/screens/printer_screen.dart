import 'dart:convert' show utf8;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:bluetooth_connector/bluetooth_connector.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thermal_printer/thermal_printer.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/style.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({Key? key}) : super(key: key);

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  BluetoothConnector flutterbluetoothconnector = BluetoothConnector();
  String name = "";
  String address = "";
  bool isLoading = false;

  List<ZebraBluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    checkPerm();

    flutterbluetoothconnector.checkBluetooth().then((value) {
      if (value == false) {
        AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.BOTTOMSLIDE,
            title: 'warning'.tr(),
            desc: 'Please turn on bluetooth'.tr(),
            btnOkText: 'I Understand'.tr(),
            dismissOnTouchOutside: false,
            btnOkOnPress: () {
              Navigator.pop(context);
            }).show();
      }
    });

    deviceList();
    getAddressConnection();
  }

  checkPerm() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }

    if (await Permission.bluetooth.status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  String generateCPCLCode(String price) {
    return """
    ^XA
    ^CWZ,E:TT0003M_.FNT^FS
    ^PW1300
    ^LL700
    ^BY2,1,75
    ^FO150,160^BCN,100,Y,N,N^FD123456789012^FS
    ^PA1,1,1,1^FS
    ^FO420,50^CI28^AZN,35,35^TBN,250,250^FD${utf8.decode(utf8.encode('بهارت مشكلة'))}^FS
    ^PA1,1,1,1^FS
    ${getPriceFieldCode(price)}
    ^PA1,1,1,1^FS
    ^FO660,170^CI28^AZN,25,25^TBN,180,230^FD${utf8.decode(utf8.encode('من 2023-04-01 الى 2023-04-15'))}^FS
    ^PQ1
    ^XZ
  """;
  }

  String getPriceFieldCode(String price) {
    double priceValue = double.tryParse(price) ?? 0.0;

    if (priceValue >= 1.0) {
      List<String> priceParts = priceValue.toStringAsFixed(2).split('.');
      String beforeComma = priceParts[0];
      String afterComma = priceParts[1];

      double beforeCommaWidth =
          (beforeComma.length * 25).toDouble(); // Adjust the width as needed
      double afterCommaWidth =
          (afterComma.length * 25).toDouble(); // Adjust the width as needed

      int totalWidth = (beforeCommaWidth + afterCommaWidth + 5)
          .toInt(); // Adjust the spacing as needed

      return """
      ^FO${575 - totalWidth ~/ 2},70^CI28^AZN,50,50^TBN,180,250^FD${utf8.decode(utf8.encode(beforeComma))}^FS
      ^FO${575 + totalWidth ~/ 2 - afterCommaWidth.toInt()},80^CI28^AZN,35,35^TBN,180,250^FD${utf8.decode(utf8.encode('.$afterComma'))}^FS
    """;
    } else {
      return "^FO550,70^CI28^AZN,35,35^TBN,180,250^FD${utf8.decode(utf8.encode(price))}^FS";
    }
  }

  // String zpl = '! U1 setvar "media.type" "label"'
  //         '! U1 setvar "device.languages" "zpl"' +
  //     '! U1 setvar "device.pnp_option" "zpl"' +
  //     '! U1 do "device.reset" "" <CR>';

  String zpl =
      '! U1 setvar "media.type" "gap"' +
      '! U1 do "device.save"' +
      '! U1 do "device.reset" "" <CR>';

  Future<void> deviceList() async {
    List<ZebraBluetoothDevice> devices = [];

    try {
      setState(() {
        isLoading = true;
      });
      devices = await FlutterZsdk.discoverBluetoothDevices()
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
      devices.forEach((d) {
        print('Device: ${d.friendlyName} [${d.mac}]');
      });
    } catch (e) {
      print('Error:$e');
    }

    if (!mounted) return;

    setState(() {
      devicesList = devices;
    });
  }

  Future<void> addressConnection(String name, String address) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString(ConfigSharedPreferences.namePrint, name);
    preferences.setString(ConfigSharedPreferences.address, address);

    getAddressConnection();
  }

  Future<void> getAddressConnection() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      name = preferences.getString(ConfigSharedPreferences.namePrint) ?? "";
      address = preferences.getString(ConfigSharedPreferences.address) ?? "";
    });
  }

  // void printTest() {
  //   var arguments = {
  //     'PrinterAdd': address,
  //     'ItemName': "بهارات مشكلة",
  //     'Price': "3.500",
  //     'Barcode': "12345678999",
  //     'CopyCount': "1",
  //   };
  //
  //   var platform = const MethodChannel('com.samehgroup.samehgroup/khh');
  //   platform.invokeListMethod('print', arguments);
  // }

  int levelText = 0;

  _level(ZebraBluetoothDevice d) {
    d.batteryLevel().then((t) {
      setState(() {
        levelText = int.parse(t);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      return Theme(
        data: theme.copyWith(
            colorScheme: theme.colorScheme
                .copyWith(secondary: customTheme.Primary.withAlpha(40))),
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: FxText.headlineSmall('print'.tr(),
                    color: FxAppTheme.theme.primaryColor, fontWeight: 500),
                backgroundColor: Colors.transparent,
                actions: [
                  Container(
                    width: 40,
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
                        deviceList();
                      },
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
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
                centerTitle: true,
                elevation: 0.0,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              body: (isLoading)
                  ? Center(
                      child: CircularProgressIndicator(
                        color: customTheme.Primary,
                      ),
                    )
                  : (devicesList.length < 1)
                      ? Center(child: Text("Not found any printer"))
                      : Column(
                          children: List.generate(devicesList.length, (index) {
                            _level(devicesList[index]);
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    ZebraBluetoothDevice(devicesList[index].mac,
                                            devicesList[index].friendlyName)
                                        .properties();

                                    ZebraBluetoothDevice(devicesList[index].mac,
                                            devicesList[index].friendlyName)
                                        .sendZplOverBluetooth(zpl);

                                    addressConnection(
                                        devicesList[index]
                                            .friendlyName
                                            .toString(),
                                        devicesList[index].mac.toString());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12,
                                        left: 16,
                                        right: 16,
                                        bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                        flex: 1,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            (address ==
                                                                    devicesList[
                                                                            index]
                                                                        .mac)
                                                                ? Icon(
                                                                    Icons
                                                                        .circle,
                                                                    size: 10,
                                                                    color: customTheme
                                                                        .colorSuccess,
                                                                  )
                                                                : Icon(
                                                                    Icons
                                                                        .circle,
                                                                    size: 10,
                                                                    color: customTheme
                                                                        .Primary,
                                                                  ),
                                                            SizedBox(width: 5),
                                                            FxText.titleSmall(
                                                                devicesList[index]
                                                                            .friendlyName
                                                                            .toString() ==
                                                                        ''
                                                                    ? '(unknown device)'
                                                                    : devicesList[
                                                                            index]
                                                                        .friendlyName
                                                                        .toString(),
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                                fontWeight:
                                                                    500),
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    (address ==
                                                            devicesList[index]
                                                                .mac)
                                                        ? BatteryIndicator(
                                                            batteryFromPhone:
                                                                false,
                                                            batteryLevel:
                                                                levelText,
                                                            style:
                                                                BatteryIndicatorStyle
                                                                    .values[1],
                                                            colorful: true,
                                                            showPercentNum:
                                                                true,
                                                            mainColor:
                                                                Colors.blue,
                                                            size: 18,
                                                            ratio: 3.0,
                                                            showPercentSlide:
                                                                true,
                                                          )
                                                        : Container(),
                                                    Expanded(
                                                      flex: 1,
                                                      child: FxText.bodyMedium(
                                                        devicesList[index]
                                                            .mac
                                                            .toString(),
                                                        textDirection:
                                                            TextDirection.ltr,
                                                        fontWeight: 500,
                                                        letterSpacing: 0,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: customTheme.Primary,
                                          child: Icon(Icons.print,
                                              color: customTheme.OnPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          }),
                        ),
              bottomNavigationBar: Container(
                height: 48,
                margin: paddingHorizontal.add(paddingVerticalMedium),
                child: FxButton.medium(
                    borderRadiusAll: 8,
                    // onPressed: printTest, //printTest,
                    onPressed: () => ZebraBluetoothDevice(address, name)
                        .sendZplOverBluetooth(generateCPCLCode("1.50")),
                    //printTest,
                    backgroundColor: customTheme.Primary,
                    child: FxText.labelLarge(
                      'Print Test'.tr(),
                      color: customTheme.OnPrimary,
                    )),
              )),
        ),
      );
    });
  }
}
