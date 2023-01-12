import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/images.dart';
import 'package:samehgroup/config/screens.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/extensions/widgets_extension.dart';
import 'package:samehgroup/screens/select_language_dialog.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:samehgroup/theme/theme_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  bool isDark = false;

  String username = "";
  String branchNo = "";

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    loadProfile();
  }

  Future loadProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo =
        jsonDecode(preferences.getString(ConfigSharedPreferences.userInfo)!)
            as Map<String, dynamic>;

    setState(() {
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

    Navigator.pushNamedAndRemoveUntil(
        context, Screens.login.value, (Route<dynamic> route) => false);
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
                        child: Image(
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
                                SelectLanguageDialog());
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Row(
                        children: [
                          FxContainer(
                            paddingAll: 12,
                            borderRadiusAll: 4,
                            child: Image(
                              height: 20,
                              width: 20,
                              image: AssetImage(Images.languageOutline),
                              color: CustomTheme.peach,
                            ),
                            color: CustomTheme.peach.withAlpha(20),
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
                    Divider(
                      thickness: 0.8,
                    ),
                    FxSpacing.height(16),
                    Center(
                        child: FxButton.rounded(
                      onPressed: () {
                        logout();
                      },
                      child: FxText.labelLarge(
                        'logout'.tr(),
                        color: customTheme.OnPrimary,
                      ),
                      elevation: 2,
                      backgroundColor: customTheme.Primary,
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
                            launch("tel://+962786322012");
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
