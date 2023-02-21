import 'dart:convert';
import 'dart:async';
import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart' as schedulerBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/screens.dart';
import 'package:samehgroup/extensions/theme_extension.dart';
import 'package:samehgroup/localizations/app_localization_delegate.dart';
import 'package:samehgroup/localizations/language.dart';
import 'package:samehgroup/screens/home_screen.dart';
import 'package:samehgroup/screens/login_screen.dart';
import 'package:samehgroup/screens/main_screen.dart';
import 'package:samehgroup/screens/profile_screen.dart';
import 'package:samehgroup/screens/requirements_screen.dart';
import 'package:samehgroup/screens/select_language_screen.dart';
import 'package:samehgroup/screens/update_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutx/themes/app_theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/theme/theme_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

String loadView = "";
Locale? locale;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  messaging = FirebaseMessaging.instance;

  //If subscribe based on topic then use this
  await FirebaseMessaging.instance.subscribeToTopic('flutter_notification');

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
        'flutter_notification', // id
        'flutter_notification_title', // title
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin!.initialize(initSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  AppTheme.init();

  await checkTheme();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await isUpdate();

  runApp(ChangeNotifierProvider<AppNotifier>(
    create: (context) => AppNotifier(),
    child: ChangeNotifierProvider<FxAppThemeNotifier>(
      create: (context) => FxAppThemeNotifier(),
      child: const MyApp(),
    ),
  ));
}

Future<Map> requirements(String packageName) async {
  var check = await AppCheck.getInstalledApps();
  bool isEnable = false;

  if (check!.where((i) => i.packageName == packageName).toList().isNotEmpty) {
    isEnable = await AppCheck.isAppEnabled(packageName);
  }

  var data = {
    "exists":
        check.where((i) => i.packageName == packageName).toList().isNotEmpty,
    "is_enable": isEnable
  };

  return data;
}

Future<void> isUpdate() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  var response = await http.get(Uri.parse("${Api.app}/pda"));

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  await requirements("com.masera.khh_barcodeprint").then((value) {
    preferences.setString(
        ConfigSharedPreferences.barcodePrint, jsonEncode(value));
  });

  await requirements("com.google.android.gms").then((value) {
    preferences.setString(ConfigSharedPreferences.gms, jsonEncode(value));
  });

  Map<String, dynamic> barcodePrintInfo =
      jsonDecode(preferences.getString(ConfigSharedPreferences.barcodePrint)!)
          as Map<String, dynamic>;

  Map<String, dynamic> gmsInfo =
      jsonDecode(preferences.getString(ConfigSharedPreferences.gms)!)
          as Map<String, dynamic>;

  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body);

    if ((barcodePrintInfo["exists"] == true &&
            barcodePrintInfo["is_enable"] == true) &&
        (gmsInfo["exists"] == true && gmsInfo["is_enable"] == true)) {
      if (responseBody["data"][0] != null) {
        Version currentVersion = Version.parse(packageInfo.version.toString());
        Version latestVersion =
            Version.parse(responseBody["data"][0]["version"].toString());

        if (latestVersion > currentVersion) {
          loadView = Screens.update.value;
        } else {
          loadView = await isLogin();
        }
      } else {
        loadView = await isLogin();
      }
    } else {
      loadView = Screens.requirements.value;
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

Future<void> checkTheme() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  if (sharedPreferences.getString("theme_mode") == null) {
    sharedPreferences.setString(
        "theme_mode",
        (schedulerBinding.SchedulerBinding.instance.platformDispatcher
                    .platformBrightness ==
                Brightness.light)
            ? ThemeType.light.toText
            : ThemeType.dark.toText);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        String action = jsonEncode(message.data);

        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                priority: Priority.high,
                importance: Importance.max,
                setAsGroupSummary: true,
                styleInformation: const DefaultStyleInformation(true, true),
                largeIcon:
                    const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                channelShowBadge: true,
                autoCancel: true,
                icon: '@drawable/ic_launcher',
              ),
            ),
            payload: action);
      }
      print('A new event was published!');
    });
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
            Screens.login.value: (context) => const LoginScreen(),
            Screens.main.value: (context) => const MainScreen(),
            Screens.home.value: (context) => const HomeScreen(),
            Screens.profile.value: (context) => const ProfileScreen(),
            Screens.language.value: (context) => const SelectLanguageScreen(),
            Screens.update.value: (context) => const UpdateScreen(),
            Screens.requirements.value: (context) => const Requirements()
          },
        );
      },
    );
  }

  void loadImage(BuildContext context) {
    precacheImage(const AssetImage("./assets/images/logo.png"), context);
    precacheImage(
        const AssetImage("./assets/icons/global_outline.png"), context);
    precacheImage(const AssetImage("./assets/icons/moon_outline.png"), context);
    precacheImage(
        const AssetImage("./assets/icons/paper-shredder.png"), context);
    precacheImage(
        const AssetImage("./assets/icons/rocket-outline.png"), context);
    precacheImage(const AssetImage("./assets/icons/sun_outline.png"), context);
  }
}
