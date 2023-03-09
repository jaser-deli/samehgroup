import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:samehgroup/common/card_picture.dart';
import 'package:samehgroup/common/take_photo.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/service/dio_upload_service.dart';
import 'package:samehgroup/service/http_upload_service.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';

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
  final DioUploadService _dioUploadService = DioUploadService();
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

  Future<void> presentAlert(BuildContext context,
      {String title = '', String message = '', Function()? ok}) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('$title'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text('$message'),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  // style: greenText,
                ),
                onPressed: ok != null ? ok : Navigator.of(context).pop,
              ),
            ],
          );
        });
  }

  void presentLoader(BuildContext context,
      {String text = 'Aguarde...',
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
        body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Column(
          children: [
            Text('Send pictures', style: TextStyle(fontSize: 17.0)),
            SizedBox(
              height: 20,
            ),
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
                        // CardPicture(),
                        // CardPicture(),
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
                          decoration: BoxDecoration(
                              // color: Colors.indigo,
                              gradient: LinearGradient(colors: [
                                Colors.indigo,
                                Colors.indigo.shade800
                              ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0))),
                          child: FxButton.medium(
                              borderRadiusAll: 8,
                              onPressed: () async {
                                // show loader
                                presentLoader(context, text: 'Wait...');

                                // calling with dio
                                var responseDataDio = await _dioUploadService
                                    .uploadPhotos(_images);

                                // calling with http
                                var responseDataHttp = await _httpUploadService
                                    .uploadPhotos(_images, widget.number);

                                // hide loader
                                Navigator.of(context).pop();

                                // showing alert dialogs
                                // await presentAlert(context,
                                //     title: 'Success Dio',
                                //     message: responseDataDio.toString());
                                await presentAlert(context,
                                    title: 'Success HTTP',
                                    message: responseDataHttp);
                              },
                              backgroundColor: customTheme.Primary,
                              child: FxText.labelLarge(
                                "Send".tr(),
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
