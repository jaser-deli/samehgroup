import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/screens/barcode_scanner_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:http/http.dart' as http;

class PricingScreen extends StatefulWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  final List<bool> _dataExpansionPanel = [true, true];

  late TextEditingController _barcodeController;
  late TextEditingController _pOldItemPriceController;

  late FocusNode _barcodeFocusNode;
  late FocusNode _pOldItemPriceFocusNode;

  bool readOnly = true;

  String itemNo = "";
  String itemName = "";
  String itemEquivelentQty = "";

  String priceOffer = "";
  String price = "";
  String normal = "";
  String mix = "";
  String set = "";

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController();
    _pOldItemPriceController = TextEditingController();

    _barcodeFocusNode = FocusNode();
    _pOldItemPriceFocusNode = FocusNode();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  Future<void> getItem() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    var response =
        await http.get(Uri.parse("${Api.pricing}/${_barcodeController.text}"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        await getOffer(
            userInfo["branch_no"], responseBody["data"]["item_barcode"]);

        setState(() {
          itemNo = responseBody["data"]["item_no"];
          itemName = responseBody["data"]["item_name"];
          itemEquivelentQty = responseBody["data"]["itm_equivelent_qty"];
        });
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

  Future<void> getOffer(
    String branchNo,
    String barcode,
  ) async {
    Map<String, dynamic> body = {
      'branch_no': branchNo,
      'barcode': barcode,
    };

    var response = await http.post(Uri.parse(Api.offer), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      setState(() {
        priceOffer = responseBody["data"]["P_NORMAL_PRICE"] ?? "";
        price = responseBody["data"]["P_SELL_PRICE"] ?? "";
        normal = responseBody["data"]["P_NORMAL_REMARK_A"] ?? "";
        mix = responseBody["data"]["P_MIX_REMARK_A"] ?? "";
        set = responseBody["data"]["P_SET_REMARK_A"] ?? "";
      });
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: FxText.headlineSmall('pricing'.tr(),
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
                autofocus: true,
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
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.qr_code),
                      color: customTheme.Primary,
                      onPressed: () {
                        scanBarcode(context).whenComplete(() async {
                          if (_barcodeController.text.isNotEmpty) {
                            _pOldItemPriceFocusNode.requestFocus();
                            await getItem();
                          }
                        });
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
              FxSpacing.height(16),
              FxTextField(
                controller: _pOldItemPriceController,
                cursorColor: customTheme.Primary,
                readOnly: readOnly,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () async {
                  validationField(
                      _barcodeController.text, 'p_e_barcode_no', getItem());
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.mode_edit_outlined,
                        color: customTheme.Primary),
                    prefixIconColor: customTheme.Primary,
                    hintText: 'تسجيل سعر الرف'.tr(),
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
                  onPressed: () {
                    validation();

                    if (priceOffer.isEmpty) {
                      // price
                      // Set And Max
                    } else {
                      // priceOffer
                      // normal
                    }
                  },
                  backgroundColor: customTheme.Primary,
                  child: FxText.labelLarge(
                    "print".tr(),
                    color: customTheme.OnPrimary,
                  )),
              FxSpacing.height(16),
              (readOnly)
                  ? Container()
                  : Container(
                      padding: FxSpacing.only(bottom: 16),
                      child: (priceOffer.isNotEmpty)
                          ? ExpansionPanelList(
                              expandedHeaderPadding: const EdgeInsets.all(0),
                              expansionCallback: (int index, bool isExpanded) {
                                setState(() {
                                  _dataExpansionPanel[index] = !isExpanded;
                                });
                              },
                              animationDuration:
                                  const Duration(milliseconds: 500),
                              children: <ExpansionPanel>[
                                ExpansionPanel(
                                    canTapOnHeader: true,
                                    headerBuilder: (BuildContext context,
                                        bool isExpanded) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            FxContainer(
                                              paddingAll: 12,
                                              borderRadiusAll: 4,
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
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
                                ExpansionPanel(
                                    canTapOnHeader: true,
                                    headerBuilder: (BuildContext context,
                                        bool isExpanded) {
                                      return Container(
                                        padding: FxSpacing.all(16),
                                        child: FxText.titleMedium(
                                            'معلومات العرض'.tr(),
                                            fontWeight: isExpanded ? 700 : 600,
                                            letterSpacing: 0),
                                      );
                                    },
                                    body: FxContainer(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            FxContainer(
                                              paddingAll: 12,
                                              borderRadiusAll: 4,
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
                                              child: Text('سعر الصنف'.tr()),
                                            ),
                                            FxSpacing.width(16),
                                            Expanded(
                                              child: FxText.bodyLarge(
                                                price,
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
                                              child: Text('سعر العرض'.tr()),
                                            ),
                                            FxSpacing.width(16),
                                            Expanded(
                                              child: FxText.bodyLarge(
                                                priceOffer,
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
                                              child: Text(
                                                  'ملاحظات عرض النورمال'.tr()),
                                            ),
                                            FxSpacing.width(16),
                                            Expanded(
                                              child: FxText.bodyLarge(
                                                normal,
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
                                              child:
                                                  Text('ملاحظات عرض MIX'.tr()),
                                            ),
                                            FxSpacing.width(16),
                                            Expanded(
                                              child: FxText.bodyLarge(
                                                mix,
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
                                              child:
                                                  Text('ملاحظات عرض SET'.tr()),
                                            ),
                                            FxSpacing.width(16),
                                            Expanded(
                                              child: FxText.bodyLarge(
                                                set,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          thickness: 0.8,
                                        ),
                                      ],
                                    )),
                                    isExpanded: _dataExpansionPanel[1])
                              ],
                            )
                          : ExpansionPanelList(
                              expandedHeaderPadding: const EdgeInsets.all(0),
                              expansionCallback: (int index, bool isExpanded) {
                                setState(() {
                                  _dataExpansionPanel[index] = !isExpanded;
                                });
                              },
                              animationDuration:
                                  const Duration(milliseconds: 500),
                              children: <ExpansionPanel>[
                                ExpansionPanel(
                                    canTapOnHeader: true,
                                    headerBuilder: (BuildContext context,
                                        bool isExpanded) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            FxContainer(
                                              paddingAll: 12,
                                              borderRadiusAll: 4,
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
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
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
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
                                        Row(
                                          children: [
                                            FxContainer(
                                              paddingAll: 12,
                                              borderRadiusAll: 4,
                                              color: CustomTheme.peach
                                                  .withAlpha(20),
                                              child: Text('price'.tr()),
                                            ),
                                            FxSpacing.width(16),
                                            Expanded(
                                              child: FxText.bodyLarge(
                                                price,
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
                              ],
                            ),
                    ),
              FxSpacing.height(16),
            ],
          ),
        );
      },
    );
  }

  void validation() {
    if (_barcodeController.text.isNotEmpty) {
      // save(branchNo.toString(), itemNo.toString(), _barcodeController.text,
      //     itemEquivelentQty, _quantityDestroyController.text);

      //clear filed
      clearFiled();
    } else {
      validationField(_barcodeController.text, 'p_e_barcode_no', getItem());
    }
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

      _barcodeFocusNode.requestFocus();
    } else {
      setState(() {
        readOnly = false;
      });

      await future;
    }
  }

  void clearFiled() {
    _barcodeController.clear();
    _pOldItemPriceController.clear();

    _barcodeFocusNode.requestFocus();

    setState(() {
      readOnly = true;
    });
  }
}
