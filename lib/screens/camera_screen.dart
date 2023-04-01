import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samehgroup/common/card_picture.dart';
import 'package:samehgroup/common/take_photo.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/service/http_upload_service.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CameraScreen extends StatefulWidget {
  final number;

  const CameraScreen({Key? key, this.number}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  final HttpUploadService _httpUploadService = HttpUploadService();
  late CameraDescription _cameraDescription;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    availableCameras().then((cameras) {
      final camera = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.back)
          .toList()
          .first;
      setState(() {
        _cameraDescription = camera;
      });
    }).catchError((err) {
      print(err);
    });
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
    return Scaffold(
        appBar: AppBar(
          title: FxText.headlineSmall('صور الفوتير'.tr(),
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  height: 400,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                            CardPicture(
                              onTap: () async {
                                final String? imagePath =
                                    await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => TakePhoto(
                                                  camera: _cameraDescription,
                                                )));

                                print('imagepath: $imagePath');
                                if (imagePath != null) {
                                  setState(() {
                                    _images.add(imagePath);
                                  });
                                }
                              },
                            ),
                          ] +
                          _images
                              .map((String path) => CardPicture(
                                    imagePath: path,
                                  ))
                              .toList()),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              decoration: const BoxDecoration(
                                  // color: Colors.indigo,
                                  gradient: LinearGradient(colors: [
                                    Color(0xfffe0000),
                                    Color(0xfffe0000)
                                  ]),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                              child: FxButton.medium(
                                  borderRadiusAll: 8,
                                  onPressed: () async {
                                    // show loader
                                    presentLoader(context,
                                        text: 'الرجاء الأنتظار لحظات...');

                                    // calling with http
                                    var responseDataHttp =
                                        await _httpUploadService.uploadPhotos(
                                            _images, widget.number);

                                    // hide loader
                                    Navigator.of(context).pop();

                                    // showing alert dialogs
                                    if (responseDataHttp.isNotEmpty) {
                                      showTopSnackBar(
                                        Overlay.of(context),
                                        CustomSnackBar.success(
                                          message: 'تم رفع الصور بنجاح'.tr(),
                                          // رقم الباركود غير مشمول في طلب الشراء
                                        ),
                                      );

                                      Navigator.pop(context);
                                    }
                                  },
                                  backgroundColor: customTheme.Primary,
                                  child: FxText.labelLarge(
                                    "أرسأل".tr(),
                                    color: customTheme.OnPrimary,
                                  ))),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ));
  }
}
