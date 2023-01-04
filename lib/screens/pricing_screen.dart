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
        return Scaffold(
          appBar: AppBar(
            title: FxText.headlineSmall('receiving'.tr(),
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
              // FxTextField(
              //   controller: _orderController,
              //   cursorColor: customTheme.Primary,
              //   readOnly: false,
              //   style: TextStyle(color: customTheme.Primary),
              //   keyboardType: TextInputType.phone,
              //   maxLines: 1,
              //   onTap: () {
              //     // _supplierController.clear();
              //     // _barcodeController.clear();
              //     // _quantityDestroyController.clear();
              //     // _quantityReservedController.clear();
              //     //
              //     // setState(() {
              //     //   readOnlyBarcode = true;
              //     //   readOnlyQuantity = true;
              //     // });
              //   },
              //   decoration: InputDecoration(
              //       prefixIcon: Icon(
              //         Icons.person_outline,
              //         color: customTheme.Primary,
              //       ),
              //       prefixIconColor: customTheme.Primary,
              //       hintText: 'order'.tr(),
              //       hintStyle: TextStyle(color: customTheme.Primary),
              //       fillColor: customTheme.Primary.withAlpha(40),
              //       filled: true,
              //       floatingLabelBehavior: FloatingLabelBehavior.always,
              //       counter: const Offstage(),
              //       focusedBorder: OutlineInputBorder(
              //           borderSide: BorderSide(
              //             color: customTheme.Primary,
              //             width: 1.0,
              //           ),
              //           borderRadius: BorderRadius.circular(8.0)),
              //       enabledBorder: OutlineInputBorder(
              //           borderSide: const BorderSide(
              //             color: Colors.transparent,
              //             width: 1.0,
              //           ),
              //           borderRadius: BorderRadius.circular(8.0)),
              //       border: OutlineInputBorder(
              //           borderSide: BorderSide(
              //             color: customTheme.Primary,
              //             width: 1.0,
              //           ),
              //           borderRadius: BorderRadius.circular(8.0))),
              //   inputFormatters: <TextInputFormatter>[
              //     FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
              //   ],
              // ),
              // (readOnlyBarcode)
              //     ? Container()
              //     : FxContainer(
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         FxText.titleMedium(
              //           'information_supplier'.tr(),
              //           fontWeight: 700,
              //         ),
              //         FxSpacing.height(8),
              //         Row(
              //           children: [
              //             Expanded(
              //               child: FxText.bodyLarge(
              //                 "supplierName",
              //               ),
              //             ),
              //           ],
              //         ),
              //         Divider(
              //           thickness: 0.8,
              //         ),
              //       ],
              //     )),
              FxSpacing.height(24),
              FxTextField(
                // controller: _barcodeController,
                cursorColor: customTheme.Primary,
                // readOnly: readOnlyBarcode,
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
                      icon: Icon(Icons.qr_code),
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
              // (readOnlyQuantity)
              //     ? Container()
              //     : FxContainer(
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         FxText.titleMedium(
              //           'information_item'.tr(),
              //           fontWeight: 700,
              //         ),
              //         FxSpacing.height(8),
              //         Row(
              //           children: [
              //             FxContainer(
              //               paddingAll: 12,
              //               borderRadiusAll: 4,
              //               child: Text('item_no'.tr()),
              //               color: CustomTheme.peach.withAlpha(20),
              //             ),
              //             FxSpacing.width(16),
              //             Expanded(
              //               child: FxText.bodyLarge(
              //                 "itemNo",
              //               ),
              //             ),
              //           ],
              //         ),
              //         Divider(
              //           thickness: 0.8,
              //         ),
              //         Row(
              //           children: [
              //             FxContainer(
              //               paddingAll: 12,
              //               borderRadiusAll: 4,
              //               child: Text('item_name'.tr()),
              //               color: CustomTheme.peach.withAlpha(20),
              //             ),
              //             FxSpacing.width(16),
              //             Expanded(
              //               child: FxText.bodyLarge(
              //                 "itemName",
              //               ),
              //             ),
              //           ],
              //         ),
              //         Divider(
              //           thickness: 0.8,
              //         ),
              //         Row(
              //           children: [
              //             FxContainer(
              //               paddingAll: 12,
              //               borderRadiusAll: 4,
              //               child: Text('packing'.tr()),
              //               color: CustomTheme.peach.withAlpha(20),
              //             ),
              //             FxSpacing.width(16),
              //             Expanded(
              //               child: FxText.bodyLarge(
              //                 "itemEquivelentQty",
              //               ),
              //             ),
              //           ],
              //         ),
              //         Divider(
              //           thickness: 0.8,
              //         ),
              //       ],
              //     )),
              FxSpacing.height(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 140,
                    child: FxTextField(
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
                        //   AwesomeDialog(
                        //       context: context,
                        //       dialogType: DialogType.error,
                        //       animType: AnimType.BOTTOMSLIDE,
                        //       title: 'error'.tr(),
                        //       desc: 'p_e_barcode_no'.tr(),
                        //       btnOkText: 'ok'.tr(),
                        //       btnOkOnPress: () {})
                        //       .show();
                        // } else {
                        //   setState(() {
                        //     readOnlyQuantity = false;
                        //   });
                        //   await getItem();
                        //   await returnCheck(branchNo, itemNo, supplierNo);
                        // }
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.production_quantity_limits,
                              color: customTheme.Primary),
                          prefixIconColor: customTheme.Primary,
                          hintText: 'الكمية'.tr(),
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
                            RegExp("[0-9a-zA-Z]")),
                      ],
                    ),
                  ),
                  Container(
                    width: 140,
                    child: FxTextField(
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
                        //   AwesomeDialog(
                        //       context: context,
                        //       dialogType: DialogType.error,
                        //       animType: AnimType.BOTTOMSLIDE,
                        //       title: 'error'.tr(),
                        //       desc: 'p_e_barcode_no'.tr(),
                        //       btnOkText: 'ok'.tr(),
                        //       btnOkOnPress: () {})
                        //       .show();
                        // } else {
                        //   setState(() {
                        //     readOnlyQuantity = false;
                        //   });
                        //   await getItem();
                        //   await returnCheck(branchNo, itemNo, supplierNo);
                        // }
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.payments_outlined,
                              color: customTheme.Primary),
                          prefixIconColor: customTheme.Primary,
                          hintText: 'السعر'.tr(),
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
                            RegExp("[0-9a-zA-Z]")),
                      ],
                    ),
                  ),
                ],
              ),

              FxSpacing.height(24),

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
                    "save".tr(),
                    color: customTheme.OnPrimary,
                  )),
            ],
          ),
        );
      },
    );
  }
}
