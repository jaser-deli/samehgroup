import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/screens/barcode_scanner_screen.dart';
import 'package:samehgroup/screens/camera_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ReceivingScreen extends StatefulWidget {
  const ReceivingScreen({Key? key}) : super(key: key);

  @override
  State<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  final List<bool> _dataExpansionPanel = [true];

  late TextEditingController _orderController;
  late TextEditingController _barcodeController;

  late TextEditingController _itemQtyController;
  late TextEditingController _itemPriceController;
  late TextEditingController _invQtyController;
  late TextEditingController _dateController;

  // Focus Nodes
  late FocusNode _orderFocusNode;

  bool readOnlyBarcode = true;
  bool readOnly = true;

  bool _isWriting = false;

  String supplierName = "";
  String supplierNo = "";

  String branchNo = "";
  String periodNo = "";
  String itemNo = "";
  String itemName = "";
  String itemEquivelentQty = "";

  // late CameraDescription _cameraDescription;
  // List<String> _images = [];

  @override
  void initState() {
    super.initState();
    // availableCameras().then((cameras) {
    //   final camera = cameras
    //       .where((camera) => camera.lensDirection == CameraLensDirection.back)
    //       .toList()
    //       .first;
    //   setState(() {
    //     _cameraDescription = camera;
    //   });
    // }).catchError((err) {
    //   print(err);
    // });

    _orderController = TextEditingController();
    _barcodeController = TextEditingController();

    _itemQtyController = TextEditingController();
    _itemPriceController = TextEditingController();
    _invQtyController = TextEditingController();
    _dateController = TextEditingController();

    _orderFocusNode = FocusNode();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  Future getItem() async {
    var response = await http.get(Uri.parse(
        "${Api.ricivingBarcode}/${_barcodeController.text}/${_orderController.text}"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      print(responseBody["data"]);
      if (responseBody["data"] != null) {
        itemNo = responseBody["data"]["item_no"];
        itemName = responseBody["data"]["item_name"];
        itemEquivelentQty = responseBody["data"]["itm_equivelent_qty"];
      } else {
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'رقم الباركود غير مشمول في طلب الشراء'.tr(),
            // رقم الباركود غير مشمول في طلب الشراء
          ),
        );
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

  Future getSupplier() async {
    var response = await http
        .get(Uri.parse("${Api.ricivingSupplier}/${_orderController.text}"));
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] != null) {
        setState(() {
          supplierName = responseBody["data"]["supp_name"];
          supplierNo = responseBody["data"]["supp_no"];
          periodNo = responseBody["data"]["period_no"];
          branchNo = responseBody["data"]["branch_no"];
        });
      } else {
        clearFiled();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: 'الرجاء التاكد من رقم امر الشراء'.tr(),
          ),
        );
      }
    }
  }

  void save(
      String orderNo,
      String periodNo,
      String branchNo,
      String supplierNo,
      String itemNo,
      String barcode,
      String itemEquivelentQty,
      String itemQty,
      String itemPrice,
      String date,
      String invQty) async {
    Map<String, dynamic> body = {
      'order_no': orderNo,
      'period_no': periodNo,
      'branch_no': branchNo,
      'supplier_no': supplierNo,
      'item_no': itemNo,
      'barcode': barcode,
      'item_equivelent_qty': itemEquivelentQty,
      'item_qty': itemQty,
      'item_price': itemPrice,
      'date': date,
      'inv_qty': invQty,
    };

    var response = await http.post(Uri.parse(Api.ricivingSave), body: body);
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
            padding: FxSpacing.fromLTRB(24, 30, 24, 0),
            children: [
              FxTextField(
                controller: _orderController,
                cursorColor: customTheme.Primary,
                focusNode: _orderFocusNode,
                autofocus: true,
                readOnly: false,
                style: TextStyle(color: customTheme.Primary),
                keyboardType: TextInputType.phone,
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
                    hintText: 'order'.tr(),
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
                                supplierNo,
                              ),
                            ),
                          ],
                        ),
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
                  validationField(_orderController.text,
                      'الرجاء ادخل رقم امر الشراء', getSupplier());
                },
                onChanged: (text) {
                  if (!_isWriting) {
                    _isWriting = true;
                    setState(() {});
                    Future.delayed(Duration(seconds: 2)).whenComplete(() async {
                      _isWriting = false;
                      setState(() {
                        readOnly = false;
                      });
                      await getItem();
                      setState(() {});
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
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: FxTextField(
                      controller: _itemQtyController,
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
                            RegExp(r'^\d+\.?\d*')),
                      ],
                    ),
                  ),
                  FxSpacing.width(5),
                  Expanded(
                    flex: 1,
                    child: FxTextField(
                      controller: _itemPriceController,
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
                          hintText: 'تكلفة الفاتورة'.tr(),
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
                ],
              ),

              FxSpacing.height(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: FxTextField(
                      controller: _invQtyController,
                      cursorColor: customTheme.Primary,
                      // readOnly: readOnlyQuantity,
                      style: TextStyle(color: customTheme.Primary),
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      onTap: () async {},
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.receipt_long,
                              color: customTheme.Primary),
                          prefixIconColor: customTheme.Primary,
                          hintText: 'كمية الفاتورة'.tr(),
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
                  FxSpacing.width(5),
                  Expanded(
                    flex: 1,
                    child: FxTextField(
                      controller: _dateController,
                      cursorColor: customTheme.Primary,
                      style: TextStyle(color: customTheme.Primary),
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      readOnly: true,
                      onTap: () async {
                        await DatePicker.showSimpleDatePicker(
                          context,
                          titleText: "حدد تاريخ",
                          cancelText: "الغاء",
                          confirmText: "تحديد",
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          dateFormat: "dd/MM/yyyy",
                          locale: DateTimePickerLocale.en_us,
                          looping: false,
                        ).then((value) {
                          if (value != null) {
                            var result = DateFormat('dd/MM/yyy').format(value);
                            setState(() {
                              _dateController.text = result;
                            });
                          }
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.date_range,
                              color: customTheme.Primary),
                          prefixIconColor: customTheme.Primary,
                          hintText: 'التاريخ'.tr(),
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
                    ),
                  ),
                ],
              ),

              FxSpacing.height(16),
              // FxButton.medium(
              //     borderRadiusAll: 8,
              //     onPressed: () async {
              //       final String? imagePath =
              //           await Navigator.of(context).push(MaterialPageRoute(
              //               builder: (_) => CameraScreen(
              //                     camera: _cameraDescription,
              //                   )));
              //
              //       print('imagepath: $imagePath');
              //
              //       if (imagePath != null) {
              //         setState(() {
              //           _images.add(imagePath);
              //         });
              //       }
              //
              //       // if (double.parse(_quantityReservedController.text) > 0) {
              //       //   AwesomeDialog(
              //       //       context: context,
              //       //       dialogType: DialogType.error,
              //       //       animType: AnimType.BOTTOMSLIDE,
              //       //       title: 'error'.tr(),
              //       //       desc: 't_i_is_p_a_p_a_or_c_t_t'.tr(),
              //       //       btnOkText: 'ok'.tr(),
              //       //       btnOkOnPress: () {})
              //       //       .show();
              //       // } else if (double.parse(_quantityDestroyController.text) >
              //       //     quantityDestroy) {
              //       //   AwesomeDialog(
              //       //       context: context,
              //       //       dialogType: DialogType.error,
              //       //       animType: AnimType.BOTTOMSLIDE,
              //       //       title: 'error'.tr(),
              //       //       desc: 't_r_q_is_g_t_t_c_q'.tr(),
              //       //       btnOkText: 'ok'.tr(),
              //       //       btnOkOnPress: () {})
              //       //       .show();
              //       // } else {
              //       //   save(
              //       //       supplierNo.toString(),
              //       //       branchNo.toString(),
              //       //       itemNo.toString(),
              //       //       _barcodeController.text,
              //       //       itemEquivelentQty,
              //       //       _quantityDestroyController.text);
              //       // }
              //       //
              //       // setState(() {
              //       //   readOnlyBarcode = true;
              //       //   readOnlyQuantity = true;
              //       // });
              //       //
              //       // _supplierController.clear();
              //       // _barcodeController.clear();
              //       // _quantityDestroyController.clear();
              //       // _quantityReservedController.clear();
              //     },
              //     backgroundColor: customTheme.Primary,
              //     child: FxText.labelLarge(
              //       "صورة الفاتورة".tr(),
              //       color: customTheme.OnPrimary,
              //     )),
              FxSpacing.height(16),
              FxButton.medium(
                  borderRadiusAll: 8,
                  onPressed: () {
                    if (_barcodeController.text.isNotEmpty) {
                      print(_dateController.text);
                      save(
                          _orderController.text,
                          periodNo,
                          branchNo,
                          supplierNo,
                          itemNo,
                          _barcodeController.text,
                          itemEquivelentQty,
                          _itemQtyController.text,
                          _itemPriceController.text,
                          _dateController.text,
                          _invQtyController.text);

                      clearFiledCustom();
                    } else {
                      validationField(_orderController.text,
                          'الرجاء ادخل رقم امر الشراء', getSupplier());
                    }
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

      _orderFocusNode.requestFocus();
    } else {
      setState(() {
        readOnlyBarcode = false;
      });

      await future;
    }
  }

  void clearFiled() {
    _orderController.clear();
    _barcodeController.clear();

    _orderFocusNode.requestFocus();

    setState(() {
      readOnlyBarcode = true;
      readOnly = true;
    });
  }

  void clearFiledCustom() {
    _barcodeController.clear();

    _orderFocusNode.requestFocus();

    setState(() {
      readOnly = true;
    });
  }
}
