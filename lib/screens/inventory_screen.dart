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

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late TextEditingController _barcodeController;
  late TextEditingController _quantityInventoryController;
  late TextEditingController _quantityInventoriedController;

  // read only Field
  bool readOnly = true;

  String invHead = "";
  String invDtlId = "";
  String storeNo = "";
  String itemName = "";
  String itemEquivelentQty = "";

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController();
    _quantityInventoryController = TextEditingController();
    _quantityInventoriedController = TextEditingController();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  Future<void> getItem() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    var response = await http.get(Uri.parse(
        "${Api.inventory}/${userInfo["branch_no"]}/${_barcodeController.text}"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        // set Data
        setState(() {
          invHead = responseBody["data"]["inv_head_id"];
          invDtlId = responseBody["data"]["inv_dtl_id"];
          storeNo = responseBody["data"]["store_no"];
          itemName = responseBody["data"]["item_name"];
          itemEquivelentQty = responseBody["data"]["itm_equivelent_qty"];
          _quantityInventoriedController.text =
              responseBody["data"]["inv_qnty"];
        });
      } else {
        //clear filed
        clearFiled(true);

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

  Future<void> scanBarcode(BuildContext context) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 'back'.tr(), true, ScanMode.BARCODE);

    if (!mounted) return;

    setState(() {
      if (barcodeScanRes != "-1") {
        // set Data
        _barcodeController.text = barcodeScanRes;
      }
    });
  }

  void save(String invHead, String invDtlId, String inventoryQuantity) async {
    Map<String, dynamic> body = {
      'inv_head_id': invHead,
      'inv_dtl_id': invDtlId,
      'inventory_quantity': inventoryQuantity,
    };

    var response = await http.post(Uri.parse(Api.inventorySave), body: body);
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

  void clear(String invHead, String invDtlId, String inventoryQuantity) async {
    Map<String, dynamic> body = {
      'inv_head_id': invHead,
      'inv_dtl_id': invDtlId,
      'inventory_quantity': inventoryQuantity,
    };

    var response = await http.post(Uri.parse(Api.inventoryClear), body: body);
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
            title: FxText.headlineSmall('inventory'.tr(),
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
                controller: _barcodeController,
                cursorColor: customTheme.Primary,
                readOnly: false,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () {
                  //clear filed
                  clearFiled(true);
                },
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(Icons.qr_code),
                      color: customTheme.Primary,
                      onPressed: () {
                        // Scan Barcode
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
              (readOnly)
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
                              color: CustomTheme.peach.withAlpha(20),
                              child: Text('store_no'.tr()),
                            ),
                            FxSpacing.width(16),
                            Expanded(
                              child: FxText.bodyLarge(
                                storeNo,
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
                              color: CustomTheme.peach.withAlpha(20),
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
                        Divider(
                          thickness: 0.8,
                        ),
                        Row(
                          children: [
                            FxContainer(
                              paddingAll: 12,
                              borderRadiusAll: 4,
                              color: CustomTheme.peach.withAlpha(20),
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
                        Divider(
                          thickness: 0.8,
                        ),
                      ],
                    )),
              FxSpacing.height(24),
              FxTextField(
                controller: _quantityInventoryController,
                cursorColor: customTheme.Primary,
                readOnly: readOnly,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () {
                  validationField(
                      _barcodeController.text, 'p_e_barcode_no', getItem());
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.production_quantity_limits,
                        color: customTheme.Primary),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'inventory_quantity'.tr(),
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
                controller: _quantityInventoriedController,
                cursorColor: customTheme.Primary,
                readOnly: true,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.shopping_cart_checkout,
                        color: customTheme.Primary),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'inventoried_quantity'.tr(),
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
                        // Insert Data
                        save(invHead, invDtlId,
                            _quantityInventoryController.text);

                        //clear filed
                        clearFiled(true);
                      },
                      backgroundColor: customTheme.Primary,
                      child: FxText.labelLarge(
                        "save".tr(),
                        color: customTheme.OnPrimary,
                      )),
                  FxButton.medium(
                      borderRadiusAll: 8,
                      onPressed: () async {
                        clear(invHead, invDtlId,
                            _quantityInventoryController.text);

                        await getItem();
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

  void validationField(String text, String alert, Future future) async {
    if (text.isEmpty) {
      setState(() {
        readOnly = true;
      });

      AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.BOTTOMSLIDE,
              title: 'error'.tr(),
              desc: alert.tr(),
              btnOkText: 'ok'.tr(),
              btnOkOnPress: () {})
          .show();
    } else {
      setState(() {
        readOnly = false;
      });

      await future;
    }
  }

  void clearFiled(bool flag) {
    _barcodeController.clear();
    _quantityInventoryController.clear();
    _quantityInventoriedController.clear();

    setState(() {
      readOnly = flag;
    });
  }
}
