import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter/foundation.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({Key? key}) : super(key: key);

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;



  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
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
            body: _isLoading && _blueDevices.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : _blueDevices.isNotEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Weight (" + mUnit + ")",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                mWeighingReading,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: TextButton(
                                child: Text(
                                  mButtonText,
                                ),
                                onPressed: () {
                                  setState(() {
                                    mButtonText = "Connecting...";
                                  });

                                  flutterReactiveBle.scanForDevices(
                                    withServices: [],
                                    scanMode: RB.ScanMode.lowLatency,
                                  ).listen((device) async {
                                    //code for handling results
                                    if (deviceChipseaBle == null &&
                                        device.name == "Chipsea-BLE") {
                                      deviceChipseaBle = device;

                                      flutterReactiveBle
                                          .connectToDevice(
                                        id: device.id,
                                        servicesWithCharacteristicsToDiscover:
                                            null,
                                        connectionTimeout:
                                            const Duration(seconds: 2),
                                      )
                                          .listen((connectionState) {
                                        // Handle connection state updates
                                        String _connectionStatus = "---";
                                        switch (
                                            connectionState.connectionState) {
                                          case RB
                                              .DeviceConnectionState.connected:
                                            _connectionStatus =
                                                "Connected Chipsea-BLE";
                                            break;
                                          case RB
                                              .DeviceConnectionState.connecting:
                                            _connectionStatus = "Connecting...";
                                            break;
                                          case RB.DeviceConnectionState
                                              .disconnected:
                                            _connectionStatus = "Disconnected";
                                            break;
                                          case RB.DeviceConnectionState
                                              .disconnecting:
                                            _connectionStatus =
                                                "Disconnecting...";
                                            break;
                                          default:
                                            break;
                                        }

                                        setState(() {
                                          mButtonText = _connectionStatus;
                                        });
                                      }, onError: (Object error) {
                                        // Handle a possible error
                                      });

                                      List<RB.DiscoveredService> services =
                                          await flutterReactiveBle
                                              .discoverServices(
                                        device.id,
                                      );

                                      final characteristic =
                                          RB.QualifiedCharacteristic(
                                        serviceId: RB.Uuid.parse("FFF0"),
                                        characteristicId: RB.Uuid.parse("fff1"),
                                        deviceId: device.id,
                                      );
                                      flutterReactiveBle
                                          .subscribeToCharacteristic(
                                              characteristic)
                                          .listen((data) {
                                        // code to handle incoming data
                                        if (data.isNotEmpty) {
                                          List<int> _dataReading =
                                              data.sublist(0, 6);
                                          int _dataAttribute = data[6];
                                          int _dataDecimalPoint =
                                              _dataAttribute & 0x07;
                                          int _dataUnit = _dataAttribute & 0x38;

                                          String _reading =
                                              String.fromCharCodes(
                                                  _dataReading);
                                          if (_reading.isNotEmpty) {
                                            int decimalPointAt =
                                                _reading.length -
                                                    _dataDecimalPoint;
                                            String _readingFront = _reading
                                                .substring(0, decimalPointAt);
                                            String _readingBack = _reading
                                                .substring(decimalPointAt);

                                            String _unit = "no";
                                            if (_dataUnit == 8) {
                                              _unit = "kg";
                                            } else if (_dataUnit == 16) {
                                              _unit = "lb";
                                            } else if (_dataUnit == 24) {
                                              _unit = "oz";
                                            } else if (_dataUnit == 32) {
                                              _unit = "g";
                                            }

                                            setState(() {
                                              mWeighingReading = _readingFront +
                                                  "." +
                                                  _readingBack;
                                              mUnit = _unit;
                                            });
                                          }
                                        }
                                      }, onError: (dynamic error) {
                                        // code to handle errors
                                      });
                                    }
                                  }, onError: (err) {
                                    //code for handling error
                                  });
                                },
                              ),
                            ),
                            Column(
                              children: List<Widget>.generate(
                                  _blueDevices.length, (int index) {
                                return Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _blueDevices[index].address ==
                                                (_selectedDevice?.address ?? '')
                                            ? _onDisconnectDevice
                                            : () => _onSelectDevice(index),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                _blueDevices[index].name,
                                                style: TextStyle(
                                                  color: _selectedDevice
                                                              ?.address ==
                                                          _blueDevices[index]
                                                              .address
                                                      ? Colors.blue
                                                      : Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                _blueDevices[index].address,
                                                style: TextStyle(
                                                  color: _selectedDevice
                                                              ?.address ==
                                                          _blueDevices[index]
                                                              .address
                                                      ? Colors.blueGrey
                                                      : Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_loadingAtIndex == index && _isLoading)
                                      Container(
                                        height: 24.0,
                                        width: 24.0,
                                        margin:
                                            const EdgeInsets.only(right: 8.0),
                                        child: const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.blue,
                                          ),
                                        ),
                                      ),
                                    if (!_isLoading &&
                                        _blueDevices[index].address ==
                                            (_selectedDevice?.address ?? ''))
                                      TextButton(
                                        onPressed: _onPrintReceipt,
                                        child: Container(
                                          color: _selectedDevice == null
                                              ? Colors.grey
                                              : Colors.blue,
                                          padding: const EdgeInsets.all(8.0),
                                          child: const Text(
                                            'Test Print',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
                                                return Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.5);
                                              }
                                              return Theme.of(context)
                                                  .primaryColor;
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              'Scan bluetooth device',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.blue),
                            ),
                            Text(
                              'Press button scan',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
            floatingActionButton: FloatingActionButton(
              onPressed: _isLoading ? null : _onScanPressed,
              child: const Icon(Icons.search),
              backgroundColor: _isLoading ? Colors.grey : Colors.blue,
            ), // This trailing comma makes auto-formatting nicer for build methods.

            //Column(
            //                                 children: [
            //                                   InkWell(
            //                                     onTap: () => setState(() {
            //                                       _device = data;
            //                                     }),
            //                                     child: Padding(
            //                                       padding: const EdgeInsets.only(
            //                                           top: 12,
            //                                           left: 16,
            //                                           right: 16,
            //                                           bottom: 12),
            //                                       child: Row(
            //                                         mainAxisAlignment:
            //                                             MainAxisAlignment.start,
            //                                         crossAxisAlignment:
            //                                             CrossAxisAlignment.start,
            //                                         children: <Widget>[
            //                                           CircleAvatar(
            //                                             backgroundColor:
            //                                                 customTheme.Primary,
            //                                             child: Icon(Icons.print,
            //                                                 color: customTheme.OnPrimary),
            //                                           ),
            //                                           Expanded(
            //                                             flex: 1,
            //                                             child: Padding(
            //                                               padding: const EdgeInsets.only(
            //                                                   left: 16, right: 16),
            //                                               child: Column(
            //                                                 crossAxisAlignment:
            //                                                     CrossAxisAlignment.start,
            //                                                 children: <Widget>[
            //                                                   Row(
            //                                                     children: <Widget>[
            //                                                       Expanded(
            //                                                           flex: 1,
            //                                                           child:
            //                                                               FxText.titleSmall(
            //                                                                   data.name ??
            //                                                                       "",
            //                                                                   fontWeight:
            //                                                                       500)),
            //                                                     ],
            //                                                   ),
            //                                                   Row(
            //                                                     children: [
            //                                                       Expanded(
            //                                                         flex: 1,
            //                                                         child:
            //                                                             FxText.bodyMedium(
            //                                                           data.address ?? "",
            //                                                           fontWeight: 500,
            //                                                           letterSpacing: 0,
            //                                                           overflow: TextOverflow
            //                                                               .ellipsis,
            //                                                         ),
            //                                                       ),
            //                                                     ],
            //                                                   )
            //                                                 ],
            //                                               ),
            //                                             ),
            //                                           )
            //                                         ],
            //                                       ),
            //                                     ),
            //                                   ),
            //                                   const Divider(),
            //                                 ],
            //                               )
          ),
        ),
      );
    });
  }
}
