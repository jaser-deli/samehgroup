import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/screens/barcode_scanner_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TransferFromStore extends StatefulWidget {
  const TransferFromStore({Key? key}) : super(key: key);

  @override
  State<TransferFromStore> createState() => _TransferFromStoreState();
}

class _TransferFromStoreState extends State<TransferFromStore> {
  // Theme
  late CustomTheme customTheme;
  late ThemeData theme;

  final List<bool> _dataExpansionPanel = [true];

  // Text Editing
  late TextEditingController _barcodeController;
  late TextEditingController _quantityTransferController;
  late TextEditingController _quantityCurrentController;
  late TextEditingController _quantityReservedController;

  // Select dropdown
  String _chosenValueStoreFrom = "";
  String _chosenValueStoreTo = "";

  // Lists
  List stores = [];

  // read only Field
  bool readOnlyBarcode = true;
  bool readOnlyTransferQ = true;
  bool readOnlyCurrentQ = true;

  // information Data Set
  String branchNo = "";
  String itemNo = "";
  String itemName = "";
  String itemEquivelentQty = "";

  Future<void> scanBarcode(BuildContext context) async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerScreen(),
        ));
    setState(() {
      _barcodeController.text = res;
    });
  }

  Future getStores() async {
    var response = await http.get(Uri.parse(Api.stores));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      for (var i in responseBody["data"]) {
        setState(() {
          stores.add(i);
        });
      }
    }
  }

  Future getQuantityCurrent(
    String branchNo,
    String itemNo,
    String storeNo,
  ) async {
    var response = await http
        .get(Uri.parse("${Api.quantityCurrent}/$branchNo/$itemNo/$storeNo"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      setState(() {
        _quantityCurrentController.text =
            responseBody["data"][0]["quantity_current"];
      });
    }
  }

  Future getQuantityReserved(
    String branchNo,
    String storeNo,
    String itemNo,
  ) async {
    var response = await http.get(
        Uri.parse("${Api.quantityReservedStore}/$branchNo/$storeNo/$itemNo"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      setState(() {
        _quantityReservedController.text =
            responseBody["data"][0]["quantity_reserved"];
      });
    }
  }

  Future getItemBarcode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    var response;

    if (_chosenValueStoreTo == '0003') {
      response = await http.get(Uri.parse(
          "${Api.item}?branch_no=${userInfo["branch_no"]}&store_from=$_chosenValueStoreFrom&store_no=$_chosenValueStoreTo&barcode=${_barcodeController.text}"));
    } else {
      response = await http.get(Uri.parse(
          "${Api.item}?branch_no=&store_from=$_chosenValueStoreFrom&store_no=$_chosenValueStoreTo&barcode=${_barcodeController.text}"));
    }

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        await getQuantityCurrent(userInfo["branch_no"],
            responseBody["data"]["item_no"], _chosenValueStoreFrom);
        await getQuantityReserved(userInfo["branch_no"], _chosenValueStoreFrom,
            responseBody["data"]["item_no"]);

        setState(() {
          branchNo = userInfo["branch_no"];
          itemNo = responseBody["data"]["item_no"];
          itemName = responseBody["data"]["item_name"];
          itemEquivelentQty = responseBody["data"]["itm_equivelent_qty"];
        });
      } else {
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'الصنف مكفول او لايوجد رصيد لأتمام العملية'.tr(),
          ),
        );
      }
    }
  }

  void save(
      String branchNo,
      String itemNo,
      String fromStoreNo,
      String toStoreNo,
      String barcode,
      String itemEquivelentQty,
      String transQty) async {
    Map<String, dynamic> body = {
      'branch_no': branchNo,
      'from_store_no': fromStoreNo,
      'to_store_no': toStoreNo,
      'item_no': itemNo,
      'barcode': barcode,
      'item_equivelent_qty': itemEquivelentQty,
      'trans_qty': transQty,
    };

    var response = await http.post(Uri.parse(Api.storesSave), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] == 1) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: 'o_a_s'.tr(),
          ),
        );
      }
    }
  }

  void clear(
      String branchNo,
      String itemNo,
      String fromStoreNo,
      String toStoreNo,
      String barcode,
      String itemEquivelentQty,
      String transQty) async {
    Map<String, dynamic> body = {
      'branch_no': branchNo,
      'from_store_no': fromStoreNo,
      'to_store_no': toStoreNo,
      'item_no': itemNo,
      'barcode': barcode,
      'item_equivelent_qty': itemEquivelentQty,
      'trans_qty': transQty,
    };

    var response = await http.post(Uri.parse(Api.storesClear), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] == 1) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: 'q_c_s'.tr(),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController();
    _quantityCurrentController = TextEditingController();
    _quantityTransferController = TextEditingController();
    _quantityReservedController = TextEditingController();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    getStores();
  }

  void presentLoader(BuildContext context,
      {String text = 'الرجاء الأنتظار لحظات...',
      bool barrierDismissible = false,
      bool willPop = true}) {
    showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (c) {
          return WillPopScope(
            onWillPop: () async {
              return willPop;
            },
            child: AlertDialog(
              content: Container(
                child: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: FxText.headlineSmall('transfer_store'.tr(),
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
          body: ListView(
            padding: FxSpacing.fromLTRB(24, 40, 24, 0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.white,
                    ),
                    child: Container(
                      width: 145,
                      child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          hint: Text('from'.tr()),
                          value: _chosenValueStoreFrom.isNotEmpty
                              ? _chosenValueStoreFrom
                              : null,
                          onTap: () {
                            clearFiled();
                          },
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              // labelText: "From",
                              labelStyle: const TextStyle(
                                color: Color(0xFFB4B4B4),
                              ),
                              prefixIcon: Icon(
                                Icons.store_outlined,
                                color: customTheme.Primary,
                              ),
                              prefixIconColor: customTheme.Primary),
                          onChanged: (value) {
                            setState(() {
                              _chosenValueStoreFrom = value!;
                            });
                          },
                          items: stores
                              .map((item) => DropdownMenuItem<String>(
                                    value: item["store_no"],
                                    child:
                                        FxText.bodyMedium(item["store_name_a"]),
                                  ))
                              .toList()),
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.white,
                    ),
                    child: Container(
                      width: 145,
                      child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _chosenValueStoreTo.isNotEmpty
                              ? _chosenValueStoreTo
                              : null,
                          hint: Text('to'.tr()),
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customTheme.Primary, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              // labelText: "From",
                              labelStyle: const TextStyle(
                                color: Color(0xFFB4B4B4),
                              ),
                              prefixIcon: Icon(
                                Icons.store_outlined,
                                color: customTheme.Primary,
                              ),
                              prefixIconColor: customTheme.Primary),
                          onChanged: (value) {
                            setState(() {
                              _chosenValueStoreTo = value!;
                            });
                          },
                          items: stores
                              .map((item) => DropdownMenuItem<String>(
                                    value: item["store_no"],
                                    child:
                                        FxText.bodyMedium(item["store_name_a"]),
                                  ))
                              .toList()),
                    ),
                  ),
                ],
              ),
              FxSpacing.height(24),
              FxTextField(
                controller: _barcodeController,
                cursorColor: customTheme.Primary,
                readOnly: readOnlyBarcode,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () {
                  if (_chosenValueStoreFrom.isEmpty ||
                      _chosenValueStoreTo.isEmpty) {
                    setState(() {
                      readOnlyBarcode = true;
                    });

                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message: 'الرجاء اختيار المستودع المحول منه'.tr(),
                      ),
                    );
                  } else {
                    setState(() {
                      readOnlyBarcode = false;
                    });
                  }
                },
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.qr_code),
                      color: customTheme.Primary,
                      onPressed: () {
                        scanBarcode(context);
                      },
                    ),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'barcode_no'.tr(),
                    hintStyle: TextStyle(color: customTheme.Primary),
                    fillColor: customTheme.Primary.withAlpha(40),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    counter: const Offstage(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
              ),
              (readOnlyTransferQ)
                  ? Container()
                  : Container(
                      padding: FxSpacing.only(bottom: 16),
                      child: ExpansionPanelList(
                          expandedHeaderPadding: const EdgeInsets.all(0),
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              _dataExpansionPanel[index] = !isExpanded;
                            });
                          },
                          animationDuration: const Duration(milliseconds: 500),
                          children: <ExpansionPanel>[
                            ExpansionPanel(
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, bool isExpanded) {
                                  return Container(
                                    padding: FxSpacing.all(16),
                                    child: FxText.titleMedium(
                                        'information_item'.tr(),
                                        fontWeight: isExpanded ? 700 : 600,
                                        letterSpacing: 0),
                                  );
                                },
                                body: FxContainer(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        FxContainer(
                                          paddingAll: 12,
                                          borderRadiusAll: 4,
                                          color:
                                              CustomTheme.peach.withAlpha(20),
                                          child: Text('item_no'.tr()),
                                        ),
                                        FxSpacing.width(16),
                                        Expanded(
                                          child: FxText.bodyLarge(
                                            itemNo,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      thickness: 0.8,
                                    ),
                                    Row(
                                      children: [
                                        FxContainer(
                                          paddingAll: 12,
                                          borderRadiusAll: 4,
                                          color:
                                              CustomTheme.peach.withAlpha(20),
                                          child: Text('item_name'.tr()),
                                        ),
                                        FxSpacing.width(16),
                                        Expanded(
                                          child: FxText.bodyLarge(
                                            itemName,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      thickness: 0.8,
                                    ),
                                    Row(
                                      children: [
                                        FxContainer(
                                          paddingAll: 12,
                                          borderRadiusAll: 4,
                                          color:
                                              CustomTheme.peach.withAlpha(20),
                                          child: Text('packing'.tr()),
                                        ),
                                        FxSpacing.width(16),
                                        Expanded(
                                          child: FxText.bodyLarge(
                                            itemEquivelentQty,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      thickness: 0.8,
                                    ),
                                  ],
                                )),
                                isExpanded: _dataExpansionPanel[0]),
                          ]),
                    ),
              FxSpacing.height(24),
              FxTextField(
                controller: _quantityTransferController,
                cursorColor: customTheme.Primary,
                readOnly: readOnlyTransferQ,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () async {
                  if (_barcodeController.text.isEmpty) {
                    setState(() {
                      readOnlyTransferQ = true;
                    });
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message: 'p_e_barcode_no'.tr(),
                      ),
                    );
                  } else {
                    setState(() {
                      readOnlyTransferQ = false;
                    });

                    presentLoader(context, text: 'الرجاء الأنتظار لحظات...');

                    getItemBarcode()
                        .whenComplete(() => Navigator.of(context).pop());
                  }
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.production_quantity_limits,
                        color: customTheme.Primary),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'transfer_quantity'.tr(),
                    hintStyle: TextStyle(color: customTheme.Primary),
                    fillColor: customTheme.Primary.withAlpha(40),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    counter: const Offstage(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
              ),
              FxSpacing.height(24),
              FxTextField(
                enabled: false,
                controller: _quantityCurrentController,
                cursorColor: customTheme.Primary,
                readOnly: true,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.production_quantity_limits,
                        color: customTheme.Primary),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'current_quantity'.tr(),
                    hintStyle: TextStyle(color: customTheme.Primary),
                    fillColor: customTheme.Primary.withAlpha(40),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    counter: const Offstage(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
              ),
              FxSpacing.height(24),
              FxTextField(
                enabled: false,
                controller: _quantityReservedController,
                cursorColor: customTheme.Primary,
                readOnly: true,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.shopping_cart_checkout,
                        color: customTheme.Primary),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'reserved_quantity'.tr(),
                    hintStyle: TextStyle(color: customTheme.Primary),
                    fillColor: customTheme.Primary.withAlpha(40),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    counter: const Offstage(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: customTheme.Primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0))),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
              ),
              FxSpacing.height(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FxButton.medium(
                      borderRadiusAll: 8,
                      onPressed: () {
                        validation();
                      },
                      backgroundColor: customTheme.Primary,
                      child: FxText.labelLarge(
                        "save".tr(),
                        color: customTheme.OnPrimary,
                      )),
                  FxButton.medium(
                      borderRadiusAll: 8,
                      onPressed: () {
                        clear(
                            branchNo,
                            itemNo,
                            _chosenValueStoreFrom,
                            _chosenValueStoreTo,
                            _barcodeController.text,
                            itemEquivelentQty,
                            _quantityTransferController.text);
                      },
                      backgroundColor: customTheme.Primary,
                      child: FxText.labelLarge(
                        "clear".tr(),
                        color: customTheme.OnPrimary,
                      )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void validation() {
    if (_barcodeController.text.isNotEmpty) {
      if (double.parse(_quantityReservedController.text) > 0) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 't_i_is_p_a_p_a_or_c_t_t'.tr(),
          ),
        );
      } else if (double.parse(_quantityTransferController.text) >
          double.parse(_quantityCurrentController.text)) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'الكمية المحولة اكبر من الكمية الحاليه'.tr(),
          ),
        );
      } else {
        save(
            branchNo,
            itemNo,
            _chosenValueStoreFrom,
            _chosenValueStoreTo,
            _barcodeController.text,
            itemEquivelentQty,
            _quantityTransferController.text);

        clearFiledCustom();
      }
    } else {
      presentLoader(context, text: 'الرجاء الأنتظار لحظات...');

      validationField(_barcodeController.text, 'p_e_barcode_no',
          getItemBarcode().whenComplete(() => Navigator.of(context).pop()));
    }
  }

  void validationField(String text, String alert, Future future) async {
    if (text.isEmpty) {
      setState(() {
        readOnlyBarcode = true;
      });

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: alert.tr(),
        ),
      );
    } else {
      setState(() {
        readOnlyBarcode = false;
      });

      await future;
    }
  }

  void clearFiled() {
    _barcodeController.clear();
    _quantityTransferController.clear();
    _quantityCurrentController.clear();
    _quantityReservedController.clear();

    setState(() {
      _chosenValueStoreFrom = "";
      _chosenValueStoreTo = "";
      readOnlyBarcode = true;
      readOnlyTransferQ = true;
      readOnlyCurrentQ = true;
    });
  }

  void clearFiledCustom() {
    _barcodeController.clear();
    _quantityTransferController.clear();
    _quantityCurrentController.clear();
    _quantityReservedController.clear();

    setState(() {
      readOnlyBarcode = true;
      readOnlyTransferQ = true;
      readOnlyCurrentQ = true;
    });
  }
}
