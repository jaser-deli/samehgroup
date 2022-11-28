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

class TransferFromBranch extends StatefulWidget {
  const TransferFromBranch({Key? key}) : super(key: key);

  @override
  State<TransferFromBranch> createState() => _TransferFromBranchState();
}

class _TransferFromBranchState extends State<TransferFromBranch> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late TextEditingController _barcodeController;
  late TextEditingController _quantityTransferController;
  late TextEditingController _quantityCurrentController;
  late TextEditingController _quantityReservedController;

  List branches = [];

  String _chosenValueBranchTo = "";

  String branchNo = "";
  String itemNo = "";
  String itemName = "";
  String itemEquivelentQty = "";

  bool readOnlyBarcode = true;
  bool readOnlyTransferQ = true;
  bool readOnlyCurrentQ = true;

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

  Future getBranches() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    var response =
        await http.get(Uri.parse("${Api.branches}/${userInfo["branch_no"]}"));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      for (var i in responseBody["data"]) {
        setState(() {
          branches.add(i);
        });
      }
    }
  }

  Future getQuantityCurrent(
    String branchNo,
    String itemNo,
  ) async {
    var response = await http
        .get(Uri.parse("${Api.quantityCurrentBranch}/$branchNo/$itemNo"));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      setState(() {
        // set Data
        _quantityCurrentController.text =
            responseBody["data"][0]["quantity_current"];
      });
    }
  }

  Future getQuantityReserved(
    String branchNo,
    String itemNo,
  ) async {
    var response = await http
        .get(Uri.parse("${Api.quantityReservedBranch}/$branchNo/$itemNo"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      setState(() {
        // set Data
        _quantityReservedController.text =
            responseBody["data"][0]["quantity_reserved"];
      });
    }
  }

  Future getItemBarcode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // get User Info
    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    var response = await http
        .get(Uri.parse("${Api.itemBranch}/${_barcodeController.text}"));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        await getQuantityCurrent(
            userInfo["branch_no"], responseBody["data"]["item_no"]);
        await getQuantityReserved(
            userInfo["branch_no"], responseBody["data"]["item_no"]);

        setState(() {
          branchNo = userInfo["branch_no"];
          itemNo = responseBody["data"]["item_no"];
          itemName = responseBody["data"]["item_name"];
          itemEquivelentQty = responseBody["data"]["itm_equivelent_qty"];
        });
      } else {
        //clear filed
        clearField(true);

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

  void save(String branchNo, String toBranchNo, String itemNo, String barcode,
      String itemEquivelentQty, String transQty) async {
    Map<String, dynamic> body = {
      'branch_no': branchNo,
      'to_branch_no': toBranchNo,
      'item_no': itemNo,
      'barcode': barcode,
      'item_equivelent_qty': itemEquivelentQty,
      'trans_qty': transQty,
    };

    var response = await http.post(Uri.parse(Api.branchSave), body: body);
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

  void clear(String branchNo, String toBranchNo, String itemNo, String barcode,
      String itemEquivelentQty, String transQty) async {
    Map<String, dynamic> body = {
      'branch_no': branchNo,
      'to_branch_no': toBranchNo,
      'item_no': itemNo,
      'barcode': barcode,
      'item_equivelent_qty': itemEquivelentQty,
      'trans_qty': transQty,
    };

    var response = await http.post(Uri.parse(Api.branchClear), body: body);
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
  void initState() {
    super.initState();
    _barcodeController = TextEditingController();
    _quantityCurrentController = TextEditingController();
    _quantityTransferController = TextEditingController();
    _quantityReservedController = TextEditingController();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    getBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: FxText.headlineSmall('transfer_branch'.tr(),
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
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.white,
                ),
                child: Container(
                  width: 145,
                  child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      hint: Text('to'.tr()),
                      value: _chosenValueBranchTo.isNotEmpty
                          ? _chosenValueBranchTo
                          : null,
                      onTap: () {
                        _barcodeController.clear();
                        _quantityTransferController.clear();
                        _quantityCurrentController.clear();
                        _quantityReservedController.clear();

                        setState(() {
                          _chosenValueBranchTo = "";

                          readOnlyBarcode = true;
                          readOnlyTransferQ = true;
                          readOnlyCurrentQ = true;
                        });
                      },
                      decoration: new InputDecoration(
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
                          labelStyle: TextStyle(
                            color: Color(0xFFB4B4B4),
                          ),
                          prefixIcon: Icon(
                            Icons.store_outlined,
                            color: customTheme.Primary,
                          ),
                          prefixIconColor: customTheme.Primary),
                      onChanged: (value) {
                        setState(() {
                          _chosenValueBranchTo = value!;
                        });
                      },
                      items: branches
                          .map((item) => DropdownMenuItem<String>(
                                child: FxText.bodyMedium(item["branch_name_a"]),
                                value: item["branch_no"],
                              ))
                          .toList()),
                ),
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
                  if (_chosenValueBranchTo.isEmpty) {
                    setState(() {
                      readOnlyBarcode = true;
                    });

                    AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.BOTTOMSLIDE,
                            title: 'error'.tr(),
                            desc: 'الرجاء اختيار المستودع المحول منه'.tr(),
                            btnOkText: 'ok'.tr(),
                            btnOkOnPress: () {})
                        .show();
                  } else {
                    setState(() {
                      readOnlyBarcode = false;
                    });
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
              (readOnlyTransferQ)
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
                      readOnlyTransferQ = false;
                    });

                    getItemBarcode();
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
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
                        } else if (int.parse(_quantityTransferController.text) >
                            int.parse(_quantityCurrentController.text)) {
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'error'.tr(),
                                  desc: 'الكمية المحولة اكبر من الكمية الحاليه'
                                      .tr(),
                                  btnOkText: 'ok'.tr(),
                                  btnOkOnPress: () {})
                              .show();
                        } else {
                          save(
                              branchNo,
                              _chosenValueBranchTo,
                              itemNo,
                              _barcodeController.text,
                              itemEquivelentQty,
                              _quantityTransferController.text);

                          _barcodeController.clear();
                          _quantityTransferController.clear();
                          _quantityCurrentController.clear();
                          _quantityReservedController.clear();

                          setState(() {
                            _chosenValueBranchTo = "";

                            readOnlyBarcode = true;
                            readOnlyTransferQ = true;
                            readOnlyCurrentQ = true;
                          });
                        }
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
                            _chosenValueBranchTo,
                            itemNo,
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

  void clearField(bool flag) {
    _barcodeController.clear();
    _quantityTransferController.clear();
    _quantityCurrentController.clear();
    _quantityReservedController.clear();

    setState(() {
      _chosenValueBranchTo = "";
      readOnlyBarcode = flag;
      readOnlyTransferQ = flag;
      readOnlyCurrentQ = flag;
    });
  }
}
