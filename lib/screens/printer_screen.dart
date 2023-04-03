import 'dart:convert' show utf8;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bluetooth_connector/bluetooth_connector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_zsdk/flutter_zsdk.dart';

// import 'package:flutter_cblue/flutter_cblue.dart';
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
  List<BtDevice> devicesList = [];
  String address = "";

  FlutterBlue flutterBlue = FlutterBlue.instance;

  List<ZebraBluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

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

    __init();
  }

  String greekString = "^XA" +
      "^XA^CI28^CW1,E:TT0003M_.TTF^LL130^FS" +
      "^MMT" +
      "^BY3,2,70" +
      "^FO250,100^BC^FD12345678^FS" +
      "^PA0,1,1,1" +
      "^FPH,1^FT300,50^A@N,50,50,TT0003M_^FH\^CI28^FD${utf8.decode(utf8.encode('تجربة'))}^FS^CI27" +
      "^XZ";

  //
  //
  // String greekString = '! U1 setvar "device.languages" "zpl"' +
  //     '! U1 setvar "device.pnp_option" "zpl"' +
  //     '! U1 do "device.reset" "" <CR>';

  // void printBT(String _str) async {
  //   print(await FlutterCblue.printToBT(printStr: _str)); // default logType
  // }

  Future<void> deviceList() async {
    List devices = await flutterbluetoothconnector.getDevices();

    devices.forEach((element) {
      setState(() {
        devicesList.add(element);
      });
    });
  }

  Future<void> addressConnection(String address) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString(ConfigSharedPreferences.address, address);

    getAddressConnection();
  }

  Future<void> getAddressConnection() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      address = preferences.getString(ConfigSharedPreferences.address) ?? "";
    });
  }

  void printTest() {
    var arguments = {
      'PrinterAdd': address,
      'ItemName': "بهارات مشكلة",
      'Price': "3.500",
      'Barcode': "12345678999",
      'CopyCount': "1",
    };

    var platform = const MethodChannel('com.samehgroup.samehgroup/khh');
    platform.invokeListMethod('print', arguments);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> __init() async {
    List<ZebraBluetoothDevice> devices = [];

    try {
      devices = await FlutterZsdk.discoverBluetoothDevices();
      devices.forEach((d) {
        print('Device: ${d.friendlyName} [${d.mac}]');
      });
    } catch (e) {
      // showDialog(context: context, child: Text(e));
      //throw e;
      print('Error:$e');
    }

    if (!mounted) return;

    setState(() {
      _devices = devices;
    });
  }

  String levelText = "Querying...";

  _level(ZebraBluetoothDevice d) {
    d.batteryLevel().then((t) {
      setState(() {
        levelText = t;
      });
    });
  }

  Widget _listPrinters() {
    List<Widget> items = [];

    if (_devices.length < 1) {
      items.add(ListTile(
        title: Text("Not found any or still searching"),
      ));
    } else {
      items.addAll([
        ListTile(
          title: Text("Found ${_devices.length} device(s)"),
        ),
        SizedBox(height: 50),
      ]);
      _devices.forEach((d) {
        _level(d);
        items.add(
          ListTile(
            title: Text(d.friendlyName),
            subtitle: Text(d.mac + "[%${levelText}]"),
            leading: IconButton(
                icon: Icon(Icons.list), onPressed: () => d.properties()),
            trailing: IconButton(
              icon: Icon(Icons.print),
              onPressed: () => d.sendZplOverBluetooth(greekString),
            ),
          ),
        );
      });
    }

    return ListView(
      padding: EdgeInsets.all(24),
      children: items,
    );
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
            body: _listPrinters(),
            // body: Column(
            //   children: List.generate(
            //       devicesList.length,
            //       (index) => Column(
            //             children: [
            //               InkWell(
            //                 onTap: () async {
            //                   addressConnection(
            //                       devicesList[index].address.toString());
            //                 },
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                       top: 12, left: 16, right: 16, bottom: 12),
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.start,
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: <Widget>[
            //                       Expanded(
            //                         flex: 1,
            //                         child: Padding(
            //                           padding: const EdgeInsets.only(
            //                               left: 16, right: 16),
            //                           child: Column(
            //                             crossAxisAlignment:
            //                                 CrossAxisAlignment.start,
            //                             children: <Widget>[
            //                               Row(
            //                                 children: <Widget>[
            //                                   Expanded(
            //                                       flex: 1,
            //                                       child: FxText.titleSmall(
            //                                           devicesList[index]
            //                                                       .name
            //                                                       .toString() ==
            //                                                   ''
            //                                               ? '(unknown device)'
            //                                               : devicesList[index]
            //                                                   .name
            //                                                   .toString(),
            //                                           textDirection:
            //                                               TextDirection.ltr,
            //                                           fontWeight: 500)),
            //                                 ],
            //                               ),
            //                               Row(
            //                                 children: [
            //                                   (devicesList[index]
            //                                               .address
            //                                               .toString() ==
            //                                           address)
            //                                       ? Icon(
            //                                           Icons.circle,
            //                                           size: 10,
            //                                           color: customTheme
            //                                               .colorSuccess,
            //                                         )
            //                                       : Icon(
            //                                           Icons.circle,
            //                                           size: 10,
            //                                           color:
            //                                               customTheme.Primary,
            //                                         ),
            //                                   Expanded(
            //                                     flex: 1,
            //                                     child: FxText.bodyMedium(
            //                                       devicesList[index]
            //                                           .address
            //                                           .toString(),
            //                                       textDirection:
            //                                           TextDirection.ltr,
            //                                       fontWeight: 500,
            //                                       letterSpacing: 0,
            //                                       overflow:
            //                                           TextOverflow.ellipsis,
            //                                     ),
            //                                   ),
            //                                 ],
            //                               )
            //                             ],
            //                           ),
            //                         ),
            //                       ),
            //                       CircleAvatar(
            //                         backgroundColor: customTheme.Primary,
            //                         child: Icon(Icons.print,
            //                             color: customTheme.OnPrimary),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //               const Divider(),
            //             ],
            //           )),
            // ),
            // bottomNavigationBar: Container(
            //   height: 48,
            //   margin: paddingHorizontal.add(paddingVerticalMedium),
            //   child: FxButton.medium(
            //       borderRadiusAll: 8,
            //       // onPressed: printTest, //printTest,
            //       onPressed: () {
            //         // printBT(greekString);
            //         print(_devices);
            //       }, //printTest,
            //       backgroundColor: customTheme.Primary,
            //       child: FxText.labelLarge(
            //         'Print Test'.tr(),
            //         color: customTheme.OnPrimary,
            //       )),
            // )
          ),
        ),
      );
    });
  }
}
