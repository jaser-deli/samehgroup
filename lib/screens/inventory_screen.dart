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

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Theme
  late CustomTheme customTheme;
  late ThemeData theme;

  final List<bool> _dataExpansionPanel = [true];

  // Text Editing
  late TextEditingController _barcodeController;
  late TextEditingController _quantityInventoryController;
  late TextEditingController _quantityInventoriedController;

  // Focus Nodes
  late FocusNode _barcodeFocusNode;
  late FocusNode _quantityInventoryFocusNode;

  // read only Field
  bool readOnly = true;

  // information Data Set
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

    _barcodeFocusNode = FocusNode();
    _quantityInventoryFocusNode = FocusNode();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    _barcodeFocusNode.requestFocus();
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
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'p_c_t_b_n_e'.tr(),
          ),
        );

        _barcodeFocusNode.requestFocus();
      }
    }
  }

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

  void save(String invHead, String invDtlId, String inventoryQuantity,
      String barcode, BuildContext context) async {
    Map<String, dynamic> body = {
      'inv_head_id': invHead,
      'inv_dtl_id': invDtlId,
      'inventory_quantity': inventoryQuantity,
      'item_barcode': barcode,
    };

    var response = await http.post(Uri.parse(Api.inventorySave), body: body);
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
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: 'q_c_s'.tr(),
          ),
        );
      }
    }
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
            padding: FxSpacing.fromLTRB(24, 30, 24, 0),
            children: [
              FxTextField(
                controller: _barcodeController,
                cursorColor: customTheme.Primary,
                focusNode: _barcodeFocusNode,
                readOnly: false,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () {
                  //clear filed
                  clearFiled();
                },
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.qr_code),
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
              ),
              (readOnly)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 2,
                    child: FxTextField(
                      controller: _quantityInventoryController,
                      focusNode: _quantityInventoryFocusNode,
                      cursorColor: customTheme.Primary,
                      readOnly: readOnly,
                      style: TextStyle(color: customTheme.Primary),
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      onTap: () {
                        presentLoader(context,
                            text: 'الرجاء الأنتظار لحظات...');

                        validationField(
                            _barcodeController.text,
                            'p_e_barcode_no',
                            getItem().whenComplete(
                                () => Navigator.of(context).pop()));
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
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d*')),
                      ],
                    ),
                  ),
                  Expanded(child: FxSpacing.height(24)),
                  Expanded(
                    flex: 1,
                    child: FxButton.medium(
                        borderRadiusAll: 8,
                        onPressed: () {
                          save(
                              invHead,
                              invDtlId,
                              _quantityInventoryController.text,
                              _barcodeController.text,
                              context);

                          clearFiled();

                          _quantityInventoryFocusNode.requestFocus();
                        },
                        backgroundColor: customTheme.Primary,
                        child: FxText.labelLarge(
                          "save".tr(),
                          color: customTheme.OnPrimary,
                        )),
                  ),
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
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
              ),
              FxSpacing.height(16),
              FxButton.medium(
                  borderRadiusAll: 8,
                  onPressed: () async {
                    clear(invHead, invDtlId, _quantityInventoryController.text);

                    presentLoader(context, text: 'الرجاء الأنتظار لحظات...');

                    await getItem()
                        .whenComplete(() => Navigator.of(context).pop());
                  },
                  backgroundColor: customTheme.Primary,
                  child: FxText.labelLarge(
                    "clear".tr(),
                    color: customTheme.OnPrimary,
                  )),
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

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: alert.tr(),
        ),
      );
    } else {
      setState(() {
        readOnly = false;
      });

      await future;
    }
  }

  void clearFiled() {
    _barcodeController.clear();
    _quantityInventoryController.clear();
    _quantityInventoriedController.clear();

    setState(() {
      readOnly = true;
    });
  }
}
