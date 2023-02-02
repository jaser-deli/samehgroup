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

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({Key? key}) : super(key: key);

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  // Theme
  late CustomTheme customTheme;
  late ThemeData theme;

  final List<bool> _dataExpansionPanel = [true];

  // Text Editing
  late TextEditingController _supplierController;
  late TextEditingController _barcodeController;
  late TextEditingController _quantityDestroyController;
  late TextEditingController _quantityReservedController;

  // Focus Nodes
  late FocusNode _supplierFocusNode;

  // read only Field
  bool readOnlyBarcode = true;
  bool readOnlyQuantity = true;

  // information Data Set
  double quantityDestroy = 0;
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

    _supplierFocusNode = FocusNode();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
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

  Future getSupplier(
    String supplierNo,
  ) async {
    var response = await http.get(Uri.parse("${Api.supplier}/$supplierNo"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        setState(() {
          supplierName = responseBody["data"]["supp_name_a"];
          supplierNo = responseBody["data"]["supp_no"];
        });
      } else {
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'p_c_t_s_n_e'.tr(),
          ),
        );
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
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'p_c_t_b_n_e'.tr(),
          ),
        );
      }
    }
  }

  Future returnCheck(String branchNo, String itemNo, String supplierNo) async {
    var response = await http
        .get(Uri.parse("${Api.returnCheck}/$branchNo/$itemNo/$supplierNo"));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (double.parse(responseBody["data"][0]["status"]) == 1) {
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 't_b_is_n_r_on_t_r'.tr(),
          ),
        );
      } else if (double.parse(responseBody["data"][0]["status"]) == 2) {
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 't_b_is_n_r_on_t_b'.tr(),
          ),
        );
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
            double.parse(responseBody["data"][0]["quantity_destroy"]);
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
            padding: FxSpacing.fromLTRB(24, 30, 24, 0),
            children: [
              FxTextField(
                controller: _supplierController,
                cursorColor: customTheme.Primary,
                focusNode: _supplierFocusNode,
                autofocus: true,
                readOnly: false,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  validation();
                },
                maxLines: 1,
                onTap: () {
                  clearFiled();
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
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
                        const Divider(
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
                  validationField(_supplierController.text, 'p_e_supplier_no',
                      getSupplier(_supplierController.text));
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
              (readOnlyQuantity)
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

                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message: 'p_e_barcode_no'.tr(),
                      ),
                    );
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

  void validation() {
    if (_barcodeController.text.isNotEmpty) {
      // if (double.parse(_quantityReservedController.text) > 0) {
      //   showTopSnackBar(
      //     Overlay.of(context),
      //     CustomSnackBar.error(
      //       message: 't_i_is_p_a_p_a_or_c_t_t'.tr(),
      //     ),
      //   );
      // } else

      if (double.parse(_quantityDestroyController.text) > quantityDestroy) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 't_r_q_is_g_t_t_c_q'.tr(),
          ),
        );
      } else {
        save(
            supplierNo.toString(),
            branchNo.toString(),
            itemNo.toString(),
            _barcodeController.text,
            itemEquivelentQty,
            _quantityDestroyController.text);

        clearFiledCustom();
      }
    } else {
      validationField(_barcodeController.text, 'p_e_barcode_no',
          getSupplier(_supplierController.text));
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

      _supplierFocusNode.requestFocus();
    } else {
      setState(() {
        readOnlyBarcode = false;
      });

      await future;
    }
  }

  void clearFiled() {
    _supplierController.clear();
    _barcodeController.clear();
    _quantityDestroyController.clear();
    _quantityReservedController.clear();

    _supplierFocusNode.requestFocus();

    setState(() {
      readOnlyBarcode = true;
      readOnlyQuantity = true;
    });
  }

  void clearFiledCustom() {
    _barcodeController.clear();
    _quantityDestroyController.clear();
    _quantityReservedController.clear();

    _supplierFocusNode.requestFocus();

    setState(() {
      readOnlyQuantity = true;
    });
  }
}
