import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({Key? key}) : super(key: key);

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late TextEditingController _supplierController;
  late TextEditingController _barcodeController;
  late TextEditingController _quantityDestroyController;
  late TextEditingController _quantityReservedController;

  bool readOnlyBarcode = true;
  bool readOnlyQuantity = true;

  int quantityDestroy = 0;

  String supplierName = "";
  String supplierNo = "";
  String branchNo = "";
  String itemNo = "";
  String itemName = "";
  String itemEquivelentQty = "";

  @override
  void initState() {
    super.initState();
    _supplierController = TextEditingController();
    _barcodeController = TextEditingController();
    _quantityDestroyController = TextEditingController();
    _quantityReservedController = TextEditingController();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  Future<void> scanBarcode(BuildContext context) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 'back'.tr(), true, ScanMode.BARCODE);

    if (!mounted) return;

    setState(() {
      if (barcodeScanRes != "-1") {
        _barcodeController.text = barcodeScanRes;
      }
    });
  }

  Future getSupplier(
    String _supplierNo,
  ) async {
    var response = await http.get(Uri.parse("${Api.supplier}/$_supplierNo"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        setState(() {
          supplierName = responseBody["data"]["supp_name_a"];
          supplierNo = responseBody["data"]["supp_no"];
        });
      } else {
        _supplierController.clear();
        _barcodeController.clear();
        _quantityDestroyController.clear();
        _quantityReservedController.clear();

        setState(() {
          readOnlyBarcode = true;
          readOnlyQuantity = true;
        });

        AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.BOTTOMSLIDE,
                title: 'error'.tr(),
                desc: 'p_c_t_s_n_e'.tr(),
                btnOkText: 'ok'.tr(),
                btnOkOnPress: () {})
            .show();
      }
    }
  }

  Future getItem() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    var response = await http.get(Uri.parse(
        "${Api.returnData}/${userInfo["branch_no"]}/${_barcodeController.text}"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        getQuantityReserved(
          responseBody["data"]["branch_no"],
          responseBody["data"]["store_no"],
          responseBody["data"]["item_no"],
        );

        getQuantityDestroy(
            responseBody["data"]["branch_no"], responseBody["data"]["item_no"]);

        branchNo = responseBody["data"]["branch_no"];
        itemNo = responseBody["data"]["item_no"];
        itemName = responseBody["data"]["item_name"];
        itemEquivelentQty = responseBody["data"]["itm_equivelent_qty"];
      } else {
        _barcodeController.clear();
        _quantityDestroyController.clear();
        _quantityReservedController.clear();

        setState(() {
          readOnlyBarcode = true;
          readOnlyQuantity = true;
        });

        AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.BOTTOMSLIDE,
                title: 'error'.tr(),
                desc: 'p_c_t_b_n_e'.tr(),
                btnOkText: 'ok'.tr(),
                btnOkOnPress: () {})
            .show();
      }
    }
  }

  Future returnCheck(String branchNo, String itemNo, String supplierNo) async {
    var response = await http
        .get(Uri.parse("${Api.returnCheck}/$branchNo/$itemNo/$supplierNo"));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (int.parse(responseBody["data"][0]["status"]) == 1) {
        setState(() {
          readOnlyBarcode = true;
          readOnlyQuantity = true;
        });

        _barcodeController.clear();
        _quantityDestroyController.clear();
        _quantityReservedController.clear();

        AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.BOTTOMSLIDE,
                title: 'error'.tr(),
                desc: 't_b_is_n_r_on_t_r'.tr(),
                btnOkText: 'ok'.tr(),
                btnOkOnPress: () {})
            .show();
      } else if (int.parse(responseBody["data"][0]["status"]) == 2) {
        setState(() {
          readOnlyBarcode = true;
          readOnlyQuantity = true;
        });

        _barcodeController.clear();
        _quantityDestroyController.clear();
        _quantityReservedController.clear();

        AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.BOTTOMSLIDE,
                title: 'error'.tr(),
                desc: 't_b_is_n_r_on_t_b'.tr(),
                btnOkText: 'ok'.tr(),
                btnOkOnPress: () {})
            .show();
      } else {
        await getItem();
      }
    }
  }

  Future getQuantityReserved(
    String branchNo,
    String storeNo,
    String itemNo,
  ) async {
    var response = await http.get(
        Uri.parse("${Api.returnQuantityReserved}/$branchNo/$storeNo/$itemNo"));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      setState(() {
        _quantityReservedController.text =
            responseBody["data"][0]["quantity_reserved"];
      });
    }
  }

  Future getQuantityDestroy(
    String branchNo,
    String itemNo,
  ) async {
    var response = await http
        .get(Uri.parse("${Api.returnQuantityDestroy}/$branchNo/$itemNo"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      setState(() {
        quantityDestroy =
            int.parse(responseBody["data"][0]["quantity_destroy"]);
      });
    }
  }

  void save(String supplierNo, String branchNo, String itemNo, barcode,
      String itemEquivelentQty, String transQty) async {
    Map<String, dynamic> body = {
      'supp_no': supplierNo,
      'branch_no': branchNo,
      'item_no': itemNo,
      'barcode': barcode,
      'item_equivelent_qty': itemEquivelentQty,
      'trans_qty': transQty,
    };

    var response = await http.post(Uri.parse(Api.returnSave), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != 1) {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.BOTTOMSLIDE,
                title: 'error'.tr(),
                desc: 'a_e_o'.tr(),
                btnOkText: 'ok'.tr(),
                btnOkOnPress: () {})
            .show();
      }
    }
  }

  void clear(String supplierNo, String branchNo, String itemNo, barcode,
      String itemEquivelentQty, String transQty) async {
    Map<String, dynamic> body = {
      'supp_no': supplierNo,
      'branch_no': branchNo,
      'item_no': itemNo,
      'barcode': barcode,
      'item_equivelent_qty': itemEquivelentQty,
      'trans_qty': transQty,
    };

    var response = await http.post(Uri.parse(Api.returnClear), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] == 1) {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.BOTTOMSLIDE,
                title: 'success'.tr(),
                desc: 'q_c_s'.tr(),
                btnOkText: 'ok'.tr(),
                btnOkOnPress: () {})
            .show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: FxText.headlineSmall('returns'.tr(),
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
            padding: FxSpacing.fromLTRB(24, 60, 24, 0),
            children: [
              FxTextField(
                controller: _supplierController,
                cursorColor: customTheme.Primary,
                readOnly: false,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () {
                  _supplierController.clear();
                  _barcodeController.clear();
                  _quantityDestroyController.clear();
                  _quantityReservedController.clear();

                  setState(() {
                    readOnlyBarcode = true;
                    readOnlyQuantity = true;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: customTheme.Primary,
                    ),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'supplier_no'.tr(),
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                ],
              ),
              (readOnlyBarcode)
                  ? Container()
                  : FxContainer(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.titleMedium(
                          'information_supplier'.tr(),
                          fontWeight: 700,
                        ),
                        FxSpacing.height(8),
                        Row(
                          children: [
                            Expanded(
                              child: FxText.bodyLarge(
                                supplierName,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.8,
                        ),
                      ],
                    )),
              FxSpacing.height(24),
              FxTextField(
                controller: _barcodeController,
                cursorColor: customTheme.Primary,
                readOnly: readOnlyBarcode,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () {
                  if (_supplierController.text.isEmpty) {
                    setState(() {
                      readOnlyBarcode = true;
                    });

                    AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.BOTTOMSLIDE,
                            title: 'error'.tr(),
                            desc: 'p_e_supplier_no'.tr(),
                            btnOkText: 'ok'.tr(),
                            btnOkOnPress: () {})
                        .show();
                  } else {
                    setState(() {
                      readOnlyBarcode = false;
                    });

                    getSupplier(_supplierController.text);

                    // await getItem();
                  }
                },
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(Icons.qr_code),
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                ],
              ),
              (readOnlyQuantity)
                  ? Container()
                  : FxContainer(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.titleMedium(
                          'information_item'.tr(),
                          fontWeight: 700,
                        ),
                        FxSpacing.height(8),
                        Row(
                          children: [
                            FxContainer(
                              paddingAll: 12,
                              borderRadiusAll: 4,
                              child: Text('item_no'.tr()),
                              color: CustomTheme.peach.withAlpha(20),
                            ),
                            FxSpacing.width(16),
                            Expanded(
                              child: FxText.bodyLarge(
                                itemNo,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.8,
                        ),
                        Row(
                          children: [
                            FxContainer(
                              paddingAll: 12,
                              borderRadiusAll: 4,
                              child: Text('item_name'.tr()),
                              color: CustomTheme.peach.withAlpha(20),
                            ),
                            FxSpacing.width(16),
                            Expanded(
                              child: FxText.bodyLarge(
                                itemName,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.8,
                        ),
                        Row(
                          children: [
                            FxContainer(
                              paddingAll: 12,
                              borderRadiusAll: 4,
                              child: Text('packing'.tr()),
                              color: CustomTheme.peach.withAlpha(20),
                            ),
                            FxSpacing.width(16),
                            Expanded(
                              child: FxText.bodyLarge(
                                itemEquivelentQty,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.8,
                        ),
                      ],
                    )),
              FxSpacing.height(24),
              FxTextField(
                controller: _quantityDestroyController,
                cursorColor: customTheme.Primary,
                readOnly: readOnlyQuantity,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () async {
                  if (_barcodeController.text.isEmpty) {
                    setState(() {
                      readOnlyQuantity = true;
                    });

                    AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.BOTTOMSLIDE,
                            title: 'error'.tr(),
                            desc: 'p_e_barcode_no'.tr(),
                            btnOkText: 'ok'.tr(),
                            btnOkOnPress: () {})
                        .show();
                  } else {
                    setState(() {
                      readOnlyQuantity = false;
                    });
                    await getItem();
                    await returnCheck(branchNo, itemNo, supplierNo);
                  }
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.production_quantity_limits,
                        color: customTheme.Primary),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'return_quantity'.tr(),
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                ],
              ),
              FxSpacing.height(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FxButton.medium(
                      borderRadiusAll: 8,
                      onPressed: () {
                        if (int.parse(_quantityReservedController.text) > 0) {
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'error'.tr(),
                                  desc: 't_i_is_p_a_p_a_or_c_t_t'.tr(),
                                  btnOkText: 'ok'.tr(),
                                  btnOkOnPress: () {})
                              .show();
                        } else if (int.parse(_quantityDestroyController.text) >
                            quantityDestroy) {
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'error'.tr(),
                                  desc: 't_r_q_is_g_t_t_c_q'.tr(),
                                  btnOkText: 'ok'.tr(),
                                  btnOkOnPress: () {})
                              .show();
                        } else {
                          save(
                              supplierNo.toString(),
                              branchNo.toString(),
                              itemNo.toString(),
                              _barcodeController.text,
                              itemEquivelentQty,
                              _quantityDestroyController.text);
                        }

                        setState(() {
                          readOnlyBarcode = true;
                          readOnlyQuantity = true;
                        });

                        _supplierController.clear();
                        _barcodeController.clear();
                        _quantityDestroyController.clear();
                        _quantityReservedController.clear();
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
                            supplierNo.toString(),
                            branchNo.toString(),
                            itemNo.toString(),
                            _barcodeController.text,
                            itemEquivelentQty,
                            _quantityDestroyController.text);
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
}
