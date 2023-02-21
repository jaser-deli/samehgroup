import 'dart:convert';
import 'dart:io';
import 'package:appcheck/appcheck.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/style.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/screens/notification_item_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool gms = false;
  bool isEnableGms = false;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    loadRequirements();
  }

  Future loadRequirements() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> barcodePrintInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.barcodePrint)!)
            as Map<String, dynamic>;

    Map<String, dynamic> gmsInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.gms)!)
            as Map<String, dynamic>;

    setState(() {
      barcodePrint = barcodePrintInfo["exists"];
      isEnableBarcodePrint = barcodePrintInfo["is_enable"];

      gms = gmsInfo["exists"];
      isEnableGms = gmsInfo["is_enable"];
    });
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
                            onTap: () {
                              launch(
                                  "https://drive.google.com/file/d/1p5npm7BXCT8p5n46h3DzIcBHyod0ziIb/view?usp=sharing");
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
                                                      "Barcode Print",
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
                          InkWell(
                            onTap: () {
                              launch(
                                  "https://www.apkmirror.com/apk/google-inc/google-play-services/google-play-services-23-06-16-release/google-play-services-23-06-16-040300-510240997-android-apk-download/");
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
                                                      "Google Play services",
                                                      fontWeight: 500)),
                                              FxText.titleSmall(
                                                  isEnableGms
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
                                                  gms == true
                                                      ? "Installed"
                                                      : "Not Install",
                                                  fontWeight: 500,
                                                  letterSpacing: 0,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              (isEnableGms == true)
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
                          const Divider()
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
