import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/localizations/language.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLanguageDialog extends StatefulWidget {
  const SelectLanguageDialog({Key? key}) : super(key: key);

  @override
  State<SelectLanguageDialog> createState() => _SelectLanguageDialogState();
}

class _SelectLanguageDialogState extends State<SelectLanguageDialog> {
  late CustomTheme customTheme;
  late ThemeData themeData;

  Language currentLanguage = Language.currentLanguage;
  List<Language> languages = Language.languages;

  @override
  initState() {
    customTheme = AppTheme.customTheme;

    init();
    super.initState();
  }

  Future init() async {
    currentLanguage = await getLanguage();
  }

  Future<Language> getLanguage() async {
    Language? language;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? langCode =
        sharedPreferences.getString(ConfigSharedPreferences.langCode);

    if (langCode != null) {
      setState(() {
        language = Language.findFromLocale(Locale(langCode));
      });
    }

    return language ?? languages.first;
  }

  Future<void> handleRadioValueChange(Language language) async {
    setState(() {
      Provider.of<AppNotifier>(context, listen: false).changeLanguage(language);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        themeData = AppTheme.theme;

        return Dialog(
          child: Container(
            color: FxAppTheme.theme.cardColor,
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Column(
                mainAxisSize: MainAxisSize.min, children: _buildOptions()),
          ),
        );
      },
    );
  }

  _buildOptions() {
    List<Widget> list = [];

    for (Language language in Language.languages) {
      list.add(InkWell(
        onTap: () {
          handleRadioValueChange(language);
        },
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: <Widget>[
              Radio<Language>(
                onChanged: (dynamic value) {
                  handleRadioValueChange(language);
                },
                groupValue: currentLanguage,
                value: language,
                activeColor: themeData.colorScheme.primary,
                hoverColor: FxAppTheme.theme.primaryColor,
              ),
              FxText.titleSmall(
                language.languageName,
                color: FxAppTheme.theme.primaryColor,
                fontWeight: 600,
              ),
            ],
          ),
        ),
      ));
    }

    return list;
  }
}
