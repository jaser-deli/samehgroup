import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/screens.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/localizations/app_localization_delegate.dart';
import 'package:samehgroup/localizations/language.dart';
import 'package:samehgroup/screens/home_screen.dart';
import 'package:samehgroup/screens/login_screen.dart';
import 'package:samehgroup/screens/main_screen.dart';
import 'package:samehgroup/screens/profile_screen.dart';
import 'package:samehgroup/screens/select_language_screen.dart';
import 'package:samehgroup/screens/update_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutx/themes/app_theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

String loadView = "";
Locale? locale;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
    flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.data['title'],
        message.data['body'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
          ),
        ));
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  AppTheme.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await isUpdate();
  runApp(ChangeNotifierProvider<AppNotifier>(
    create: (context) => AppNotifier(),
    child: ChangeNotifierProvider<FxAppThemeNotifier>(
      create: (context) => FxAppThemeNotifier(),
      child: MyApp(),
    ),
  ));
}

Future<void> isUpdate() async {
  var response = await http.get(Uri.parse("${Api.app}/pda"));

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body);

    Version currentVersion = Version.parse(packageInfo.version.toString());
    Version latestVersion =
        Version.parse(responseBody["data"][0]["version"].toString());

    if (responseBody["data"] != null) {
      if (latestVersion > currentVersion) {
        loadView = Screens.update.value;
      } else {
        loadView = await isLogin();
      }
    }
  }
}

Future<String> isLogin() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? token = preferences.getString(ConfigSharedPreferences.token);
  bool isLangSelect =
      preferences.getBool(ConfigSharedPreferences.isLangSelect) ?? false;

  if (isLangSelect == false) {
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

  return Locale(langCode);
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;

  @override
  void initState() {
    super.initState();

    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ));
      }
      print(notification);
    });
    getToken();
  }

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
            Screens.language.value: (context) => SelectLanguageScreen(),
            Screens.update.value: (context) => UpdateScreen()
          },
        );
      },
    );
  }

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    print(token);
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
