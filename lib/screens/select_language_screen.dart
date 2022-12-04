import 'dart:ui' as ui;
import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/widgets/button/button.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/screens.dart';
import 'package:samehgroup/config/style.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/localizations/language.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:samehgroup/widgets/tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({Key? key}) : super(key: key);

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late DateTime currentBackPressTime;
  late String _language;

  List<Locale> languages = [Locale('en', ''), Locale('ar', '')];

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    _language = ui.window.locale.languageCode;
  }

  Future changeLanguage(String language) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(ConfigSharedPreferences.langCode, language);

    Navigator.pushNamedAndRemoveUntil(
        context, Screens.login.value, (Route<dynamic> route) => false);
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;

      showTopSnackBar(
        Overlay.of(context)!,
        CustomSnackBar.error(
          message: 'p_t_b_b_to_e'.tr(),
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          bottomNavigationBar: Container(
            height: 48,
            margin: paddingHorizontal.add(paddingVerticalMedium),
            child: FxButton.medium(
                borderRadiusAll: 8,
                onPressed: () {
                  changeLanguage(_language);
                },
                backgroundColor: customTheme.Primary,
                child: FxText.labelLarge(
                  'save'.tr(),
                  color: customTheme.OnPrimary,
                )),
          ),
          body: WillPopScope(
              onWillPop: onWillPop,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      vertical: 60, horizontal: layoutPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.only(end: 25),
                        child: Icon(
                          FontAwesomeIcons.language,
                          size: 76,
                          color: theme.primaryColor,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('select_language'.tr(),
                          style: theme.textTheme.subtitle1),
                      if (languages.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        Container(
                          padding: paddingHorizontal,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius:
                                BorderRadius.circular(itemPaddingMedium),
                            boxShadow: initBoxShadow,
                          ),
                          child: Column(
                            children: List.generate(languages.length, (index) {
                              Locale lang = languages[index];
                              bool isSelected = lang.languageCode == _language;

                              return Tile(
                                title: Text(
                                  lang.convertCodeToNativeName(),
                                  style: theme.textTheme.subtitle2?.copyWith(
                                      color: isSelected
                                          ? theme.primaryColor
                                          : theme.textTheme.caption!.color),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        FeatherIcons.check,
                                        size: 16,
                                        color: theme.primaryColor,
                                      )
                                    : null,
                                isChevron: false,
                                isDivider: index < languages.length - 1,
                                onTap: () {
                                  if (!isSelected) {
                                    setState(() {
                                      _language = lang.languageCode;

                                      setState(() {
                                        Provider.of<AppNotifier>(context,
                                                listen: false)
                                            .changeLanguage(Language(
                                                Locale(_language), ''));
                                      });
                                    });
                                  }
                                },
                              );
                            }),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
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
