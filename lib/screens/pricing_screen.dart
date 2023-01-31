import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';
import 'package:samehgroup/extensions/string.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  final List<bool> _dataExpansionPanel = [true];

  late TextEditingController _barcodeController;

  bool readOnlyBarcode = false;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
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
                readOnly: false,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () {
                  // if (_supplierController.text.isEmpty) {
                  //   setState(() {
                  //     readOnlyBarcode = true;
                  //   });
                  //
                  //   AwesomeDialog(
                  //       context: context,
                  //       dialogType: DialogType.error,
                  //       animType: AnimType.BOTTOMSLIDE,
                  //       title: 'error'.tr(),
                  //       desc: 'p_e_supplier_no'.tr(),
                  //       btnOkText: 'ok'.tr(),
                  //       btnOkOnPress: () {})
                  //       .show();
                  // } else {
                  //   setState(() {
                  //     readOnlyBarcode = false;
                  //   });
                  //
                  //   getSupplier(_supplierController.text);
                  //
                  //   // await getItem();
                  // }
                },
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.qr_code),
                      color: customTheme.Primary,
                      onPressed: () {
                        // scanBarcode(context);
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
              FxSpacing.height(16),
              (readOnlyBarcode)
                  ? Container()
                  : ExpansionPanelList(
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
                                      color: CustomTheme.peach.withAlpha(20),
                                      child: Text('item_no'.tr()),
                                    ),
                                    FxSpacing.width(16),
                                    Expanded(
                                      child: FxText.bodyLarge(
                                        "itemNo",
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
                                      color: CustomTheme.peach.withAlpha(20),
                                      child: Text('item_name'.tr()),
                                    ),
                                    FxSpacing.width(16),
                                    Expanded(
                                      child: FxText.bodyLarge(
                                        "itemName",
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
                                      color: CustomTheme.peach.withAlpha(20),
                                      child: Text('packing'.tr()),
                                    ),
                                    FxSpacing.width(16),
                                    Expanded(
                                      child: FxText.bodyLarge(
                                        "itemEquivelentQty",
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
                                      color: CustomTheme.peach.withAlpha(20),
                                      child: Text('price'.tr()),
                                    ),
                                    FxSpacing.width(16),
                                    Expanded(
                                      child: FxText.bodyLarge(
                                        "price",
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
                                      color: CustomTheme.peach.withAlpha(20),
                                      child: Text('ملاحظات عرض النورمال'.tr()),
                                    ),
                                    FxSpacing.width(16),
                                    Expanded(
                                      child: FxText.bodyLarge(
                                        "price",
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
                                      color: CustomTheme.peach.withAlpha(20),
                                      child: Text('ملاحظات عرض MIX'.tr()),
                                    ),
                                    FxSpacing.width(16),
                                    Expanded(
                                      child: FxText.bodyLarge(
                                        "price",
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
                                      color: CustomTheme.peach.withAlpha(20),
                                      child: Text('ملاحظات عرض SET'.tr()),
                                    ),
                                    FxSpacing.width(16),
                                    Expanded(
                                      child: FxText.bodyLarge(
                                        "price",
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
              FxSpacing.height(16),
              FxTextField(
                // controller: _quantityDestroyController,
                cursorColor: customTheme.Primary,
                // readOnly: readOnlyQuantity,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onTap: () async {
                  // if (_barcodeController.text.isEmpty) {
                  //   setState(() {
                  //     readOnlyQuantity = true;
                  //   });
                  //
                  //   showTopSnackBar(
                  //     Overlay.of(context),
                  //     CustomSnackBar.error(
                  //       message: 'p_e_barcode_no'.tr(),
                  //     ),
                  //   );
                  // } else {
                  //   setState(() {
                  //     readOnlyQuantity = false;
                  //   });
                  //   await getItem();
                  //   await returnCheck(branchNo, itemNo, supplierNo);
                  // }
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
                    // if (double.parse(_quantityReservedController.text) > 0) {
                    //   AwesomeDialog(
                    //       context: context,
                    //       dialogType: DialogType.error,
                    //       animType: AnimType.BOTTOMSLIDE,
                    //       title: 'error'.tr(),
                    //       desc: 't_i_is_p_a_p_a_or_c_t_t'.tr(),
                    //       btnOkText: 'ok'.tr(),
                    //       btnOkOnPress: () {})
                    //       .show();
                    // } else if (double.parse(_quantityDestroyController.text) >
                    //     quantityDestroy) {
                    //   AwesomeDialog(
                    //       context: context,
                    //       dialogType: DialogType.error,
                    //       animType: AnimType.BOTTOMSLIDE,
                    //       title: 'error'.tr(),
                    //       desc: 't_r_q_is_g_t_t_c_q'.tr(),
                    //       btnOkText: 'ok'.tr(),
                    //       btnOkOnPress: () {})
                    //       .show();
                    // } else {
                    //   save(
                    //       supplierNo.toString(),
                    //       branchNo.toString(),
                    //       itemNo.toString(),
                    //       _barcodeController.text,
                    //       itemEquivelentQty,
                    //       _quantityDestroyController.text);
                    // }
                    //
                    // setState(() {
                    //   readOnlyBarcode = true;
                    //   readOnlyQuantity = true;
                    // });
                    //
                    // _supplierController.clear();
                    // _barcodeController.clear();
                    // _quantityDestroyController.clear();
                    // _quantityReservedController.clear();
                  },
                  backgroundColor: customTheme.Primary,
                  child: FxText.labelLarge(
                    "print".tr(),
                    color: customTheme.OnPrimary,
                  )),
              FxSpacing.height(16),
            ],
          ),
        );
      },
    );
  }
}
