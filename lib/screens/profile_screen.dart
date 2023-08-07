import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/images.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/extensions/widgets_extension.dart';
import 'package:samehgroup/screens/printer_screen.dart';
import 'package:samehgroup/screens/select_language_dialog.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:samehgroup/theme/theme_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  bool isDark = false;

  String version = "";
  String username = "";
  String branchNo = "";

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    initConnectivity();

    _connectivity.onConnectivityChanged.listen((result) {
      setState(() {
        _connectivityResult = result;
      });
    });

    loadProfile();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
      result = ConnectivityResult.none;
    }

    setState(() {
      _connectivityResult = result;
    });
  }

  Future loadProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // version = preferences.getString(ConfigSharedPreferences.version)!;

    setState(() {
      version = packageInfo.version;
      username = userInfo["user_name"];
      branchNo = userInfo["branch_no"];
    });
  }

  void logout() async {
    var response = await http.post(Uri.parse(Api.logout));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      AwesomeDialog(
              context: context,
              dialogType: DialogType.question,
              animType: AnimType.BOTTOMSLIDE,
              title: 'warning'.tr(),
              desc: 'a_y_s_w_to_logout'.tr(),
              btnOkText: 'yes'.tr(),
              btnOkOnPress: () {
                logoutSuccessful(responseBody["success"]);
              },
              btnCancelText: 'no'.tr(),
              btnCancelOnPress: () {})
          .show();
    }
  }

  Future logoutSuccessful(String response) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await FirebaseMessaging.instance.deleteToken();

    if (Platform.isAndroid) {
      Restart.restartApp();
    } else {
      Phoenix.rebirth(context);
    }
  }

  void changeTheme() {
    if (AppTheme.themeType == ThemeType.light) {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.dark);
    } else {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.light);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      theme = AppTheme.theme;
      customTheme = AppTheme.customTheme;

      isDark = AppTheme.themeType == ThemeType.dark;

      return Theme(
        data: theme.copyWith(
            colorScheme: theme.colorScheme
                .copyWith(secondary: customTheme.Primary.withAlpha(40))),
        child: SafeArea(
          child: Scaffold(
            body: ListView(
              padding: FxSpacing.fromLTRB(24, 36, 24, 24),
              children: [
                FxContainer(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: const Image(
                          image: AssetImage("./assets/images/logo.png"),
                          height: 100,
                          width: 100,
                        ),
                      ),
                      FxSpacing.width(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FxText.bodyLarge(username, fontWeight: 700),
                            FxSpacing.width(8),
                            FxText.bodyMedium(
                              branchNo,
                            ),
                            FxSpacing.height(8),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    changeTheme();
                                  },
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  child: FxContainer(
                                    paddingAll: 12,
                                    borderRadiusAll: 4,
                                    color: CustomTheme.occur.withAlpha(28),
                                    child: Image(
                                      height: 20,
                                      width: 20,
                                      image: AssetImage(!isDark
                                          ? Images.lightModeOutline
                                          : Images.darkModeOutline),
                                      color: CustomTheme.occur,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FxSpacing.height(24),
                FxContainer(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.titleMedium(
                      "settings".tr(),
                      fontWeight: 700,
                    ),
                    FxSpacing.height(8),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                const SelectLanguageDialog());
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Row(
                        children: [
                          FxContainer(
                            paddingAll: 12,
                            borderRadiusAll: 4,
                            color: CustomTheme.peach.withAlpha(20),
                            child: Image(
                              height: 20,
                              width: 20,
                              image: AssetImage(Images.languageOutline),
                              color: CustomTheme.peach,
                            ),
                          ),
                          FxSpacing.width(16),
                          Expanded(
                            child: FxText.bodyLarge(
                              'language'.tr(),
                            ),
                          ),
                          FxSpacing.width(16),
                          Icon(
                            FeatherIcons.chevronRight,
                            size: 18,
                            color: theme.colorScheme.onBackground,
                          ).autoDirection(),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 0.8,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PrintScreen()),
                        );
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Row(
                        children: [
                          FxContainer(
                            paddingAll: 12,
                            borderRadiusAll: 4,
                            color: CustomTheme.peach.withAlpha(20),
                            child: Image(
                              height: 20,
                              width: 20,
                              image: AssetImage(Images.printOutline),
                              color: CustomTheme.peach,
                            ),
                          ),
                          FxSpacing.width(16),
                          Expanded(
                            child: FxText.bodyLarge(
                              'print'.tr(),
                            ),
                          ),
                          FxSpacing.width(16),
                          Icon(
                            FeatherIcons.chevronRight,
                            size: 18,
                            color: theme.colorScheme.onBackground,
                          ).autoDirection(),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 0.8,
                    ),
                    InkWell(
                      onTap: _connectivityResult == ConnectivityResult.none
                          ? () {}
                          : () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //       builder: (_) => PrintScreen()),
                              // );
                            },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Row(
                        children: [
                          FxContainer(
                            paddingAll: 12,
                            borderRadiusAll: 4,
                            color: CustomTheme.peach.withAlpha(20),
                            child: Image(
                              height: 20,
                              width: 20,
                              image: AssetImage(Images.signalOutline),
                              color: CustomTheme.peach,
                            ),
                          ),
                          FxSpacing.width(16),
                          Expanded(
                            child: FxText.bodyMedium(
                              'ترحيل البينات الى الشبكة ${_connectivityResult == ConnectivityResult.none ? '(غير مفعل)' : '(مفعل)'}'
                                  .tr(),
                            ),
                          ),
                          FxSpacing.width(16),
                          Icon(
                            FeatherIcons.chevronRight,
                            size: 18,
                            color: theme.colorScheme.onBackground,
                          ).autoDirection(),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 0.8,
                    ),
                    FxSpacing.height(16),
                    Center(
                        child: FxButton.rounded(
                      onPressed: () {
                        logout();
                      },
                      elevation: 2,
                      backgroundColor: customTheme.Primary,
                      child: FxText.labelLarge(
                        'logout'.tr(),
                        color: customTheme.OnPrimary,
                      ),
                    )),
                    FxSpacing.height(10),
                    Center(
                        child: FxText.bodySmall(
                      "v-$version".tr(),
                      color: customTheme.Primary,
                      textDirection: TextDirection.ltr,
                      letterSpacing: 0,
                    ))
                  ],
                )),
                FxSpacing.height(24),
                FxContainer(
                    color: customTheme.Primary.withAlpha(40),
                    padding: FxSpacing.xy(16, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FxTwoToneIcon(
                          FxTwoToneMdiIcons.headset_mic,
                          size: 32,
                          color: customTheme.Primary,
                        ),
                        FxSpacing.width(12),
                        InkWell(
                          onTap: () {
                            launch("tel://+96278350173").catchError((error) {
                              AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.info,
                                      animType: AnimType.BOTTOMSLIDE,
                                      title: 'الدعم الفني'.tr(),
                                      desc: '0786322012'.tr(),
                                      btnOkText: 'ok'.tr(),
                                      dismissOnTouchOutside: false,
                                      btnOkOnPress: () {})
                                  .show();
                            });
                          },
                          child: FxText.bodySmall(
                            "help".tr(),
                            color: customTheme.Primary,
                            letterSpacing: 0,
                          ),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ),
      );
    });
  }
}
