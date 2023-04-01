import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/themes/app_theme.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:samehgroup/theme/custom_theme.dart';

class TakePhoto extends StatefulWidget {
  final CameraDescription? camera;

  TakePhoto({this.camera});

  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  // Theme
  late CustomTheme customTheme;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera as CameraDescription,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  Future<XFile?> takePicture() async {
    if (_controller.value.isTakingPicture) {
      return null;
    }

    try {
      XFile file = await _controller.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FxText.headlineSmall('اخذ صورة'.tr(),
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
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FloatingActionButton(
                      backgroundColor: Color(0xfffe0000),
                      onPressed: () async {
                        final file = await takePicture();
                        Navigator.of(context)
                            .pop(file != null ? file.path : null);
                      },
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                )
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
