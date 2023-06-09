import 'dart:convert';
import 'dart:io';
import 'package:app_installer/app_installer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/style.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Requirements extends StatefulWidget {
  const Requirements({Key? key}) : super(key: key);

  @override
  State<Requirements> createState() => _RequirementsState();
}

class _RequirementsState extends State<Requirements> {
  late CustomTheme customTheme;
  late ThemeData theme;

  bool barcodePrint = false;
  bool isEnableBarcodePrint = false;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    loadRequirements();

    initFlutterDownloader();
  }

  Future loadRequirements() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> barcodePrintInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.barcodePrint)!)
            as Map<String, dynamic>;

    setState(() {
      barcodePrint = barcodePrintInfo["exists"];
      isEnableBarcodePrint = barcodePrintInfo["is_enable"];
    });
  }


  Future<void> initFlutterDownloader() async {

    await Permission.storage.request();

    await FlutterDownloader.initialize(
        debug: true, // optional: set false to disable printing logs to console
        ignoreSsl: true);

    FlutterDownloader.registerCallback(Download.callback);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      return Theme(
        data: theme.copyWith(
            colorScheme: theme.colorScheme
                .copyWith(secondary: customTheme.Primary.withAlpha(40))),
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
              return false;
            },
            child: Scaffold(
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: FxText.headlineSmall('Requirements'.tr(),
                            fontWeight: 500),
                      ),
                    ),
                    FxSpacing.height(10),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(top: 10),
                        children: [
                          InkWell(
                            onTap: () async {
                              print(
                                  "onDownloadStart ${Api.urlAppPrint.toString()}");

                              await FlutterDownloader.enqueue(
                                url: Api.urlAppPrint.toString(),
                                savedDir:
                                    (await getExternalStorageDirectory())!.path,
                                showNotification: true,
                                // show download progress in status bar (for Android)
                                openFileFromNotification:
                                    true, // click on notification to open downloaded file (for Android)
                              );

                              Future.delayed(Duration(seconds: 5), () async {
                                await AppInstaller.installApk(
                                    "${(await getExternalStorageDirectory())!.path}/KHH_BarcodePrint.apk");
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 12, left: 16, right: 16, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: customTheme.Primary,
                                    child: Icon(Icons.android,
                                        color: customTheme.OnPrimary),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                  flex: 1,
                                                  child: FxText.titleSmall(
                                                      "App Print",
                                                      fontWeight: 500)),
                                              FxText.titleSmall(
                                                  isEnableBarcodePrint
                                                      ? "Enabled"
                                                      : "Disabled",
                                                  fontWeight: 500)
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: FxText.bodyMedium(
                                                  barcodePrint == true
                                                      ? "Installed"
                                                      : "Not Install",
                                                  fontWeight: 500,
                                                  letterSpacing: 0,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              (isEnableBarcodePrint == true)
                                                  ? Icon(
                                                      Icons.circle,
                                                      size: 10,
                                                      color: customTheme
                                                          .colorSuccess,
                                                    )
                                                  : Icon(
                                                      Icons.circle,
                                                      size: 10,
                                                      color:
                                                          customTheme.Primary,
                                                    )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: Container(
                  height: 48,
                  margin: paddingHorizontal.add(paddingVerticalMedium),
                  child: FxButton.medium(
                      borderRadiusAll: 8,
                      onPressed: () {
                        if (Platform.isAndroid) {
                          Restart.restartApp();
                        } else {
                          Phoenix.rebirth(context);
                        }
                      },
                      backgroundColor: customTheme.Primary,
                      child: FxText.labelLarge(
                        're-Open'.tr(),
                        color: customTheme.OnPrimary,
                      )),
                )),
          ),
        ),
      );
    });
  }
}

class Download {
  static void callback(String id, DownloadTaskStatus status, int progress) {
    print("Status => $status");
    print("Progress => $progress");
  }
}
