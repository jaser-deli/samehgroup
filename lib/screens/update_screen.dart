import 'dart:io';
import 'dart:ui' as ui;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutx/widgets/button/button.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:ota_update/ota_update.dart';
import 'package:provider/provider.dart';
import 'package:flutx/flutx.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/style.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samehgroup/localizations/language.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late String _language;

  int valuePercent = 0;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    _language = ui.window.locale.languageCode;

    init();
  }

  Future<void> init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool isLangSelect =
        sharedPreferences.getBool(ConfigSharedPreferences.isLangSelect) ??
            false;

    String langCode =
        sharedPreferences.getString(ConfigSharedPreferences.langCode) ?? "";

    setState(() {
      if (isLangSelect) {
        Provider.of<AppNotifier>(context, listen: false).changeLanguage(
            Language(
                Locale(langCode),
                Locale(langCode).convertCodeToNativeName(),
                (langCode == 'ar') ? true : false));
      } else {
        Provider.of<AppNotifier>(context, listen: false).changeLanguage(
            Language(
                Locale(_language),
                Locale(_language).convertCodeToNativeName(),
                (_language == 'ar') ? true : false));
      }
    });
  }

  Future<void> update() async {
    // RUN OTA UPDATE
    // START LISTENING FOR DOWNLOAD PROGRESS REPORTING EVENTS
    try {
      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      OtaUpdate()
          .execute(
              'http://ls.samehgroup.com:8081/LiveSales_old_new/public/storage/apps/pda.apk')
          .listen(
        (OtaEvent event) {
          if (event.status.name == "DOWNLOADING") {
            setState(() {
              valuePercent = int.parse(event.value.toString());
            });
          }
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          bottomNavigationBar: FxContainer(
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
                      launch("tel://+962786322012").catchError((error) {
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
              )),
          body: WillPopScope(
            onWillPop: () async {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
              return false;
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('new_version'.tr(), style: theme.textTheme.subtitle1),
                  const SizedBox(
                    height: 10,
                  ),
                  (valuePercent > 1)
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          child: CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 2.0,
                            percent: valuePercent / 100,
                            center: Text(
                              "$valuePercent%",
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            backgroundColor: Colors.grey[300]!,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.redAccent,
                          ))
                      : Container(),
                  Container(
                    height: 50,
                    margin: paddingHorizontal.add(paddingVerticalMedium),
                    child: FxButton.medium(
                        borderRadiusAll: 8,
                        onPressed: () async {
                          await update();
                        },
                        backgroundColor: customTheme.Primary,
                        child: FxText.labelLarge(
                          'download'.tr(),
                          color: customTheme.OnPrimary,
                        )),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

extension ConvertCodeToNativeName on Locale {
  String convertCodeToNativeName() {
    switch (this.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic - العربية';
      default:
        return 'English';
    }
  }
}
