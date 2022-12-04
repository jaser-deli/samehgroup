import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/screens.dart';
import 'package:samehgroup/localizations/app_localization_delegate.dart';
import 'package:samehgroup/localizations/language.dart';
import 'package:samehgroup/screens/home_screen.dart';
import 'package:samehgroup/screens/login_screen.dart';
import 'package:samehgroup/screens/main_screen.dart';
import 'package:samehgroup/screens/profile_screen.dart';
import 'package:samehgroup/screens/select_language_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutx/themes/app_theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String loadView = "";
Locale? locale;

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();

  AppTheme.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  loadView = await isLogin();
  runApp(ChangeNotifierProvider<AppNotifier>(
    create: (context) => AppNotifier(),
    child: ChangeNotifierProvider<FxAppThemeNotifier>(
      create: (context) => FxAppThemeNotifier(),
      child: MyApp(),
    ),
  ));
}

Future<String> isLogin() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? token = preferences.getString(ConfigSharedPreferences.token);
  String langCode =
      preferences.getString(ConfigSharedPreferences.langCode) ?? "";

  if (langCode == "" || langCode == null) {
    return Screens.language.value;
  } else if (token != "" && token != null) {
    locale = await getLanguage();
    return Screens.main.value;
  } else {
    locale = await getLanguage();
    return Screens.login.value;
  }
}

Future<Locale> getLanguage() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String langCode =
      sharedPreferences.getString(ConfigSharedPreferences.langCode) ?? "";

  return Locale(langCode, '');
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    loadImage(context);
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          builder: (context, child) {
            return Directionality(
              textDirection: AppTheme.textDirection,
              child: child!,
            );
          },
          localizationsDelegates: [
            AppLocalizationsDelegate(context),
            // Add this line
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: Language.getLocales(),
          locale: locale,
          initialRoute: loadView,
          routes: {
            Screens.login.value: (context) => LoginScreen(),
            Screens.main.value: (context) => MainScreen(),
            Screens.home.value: (context) => HomeScreen(),
            Screens.profile.value: (context) => ProfileScreen(),
            Screens.language.value: (context) => SelectLanguageScreen()
          },
        );
      },
    );
  }

  void loadImage(BuildContext context) {
    precacheImage(AssetImage("./assets/images/logo.png"), context);
    precacheImage(AssetImage("./assets/icons/global_outline.png"), context);
    precacheImage(AssetImage("./assets/icons/moon_outline.png"), context);
    precacheImage(AssetImage("./assets/icons/paper-shredder.png"), context);
    precacheImage(AssetImage("./assets/icons/rocket-outline.png"), context);
    precacheImage(AssetImage("./assets/icons/sun_outline.png"), context);
  }
}
