import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/screens/home_screen.dart';
import 'package:samehgroup/screens/notification_screen.dart';
import 'package:samehgroup/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samehgroup/theme/app_notifier.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late PageController _pageController;

  int currentIndex = 0;

  int count = 0;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    _pageController = PageController();

    init();
    notifications();
  }

  Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    //If subscribe based sent notification then use this token
    final fcmToken = await FirebaseMessaging.instance.getToken();

    Map<String, dynamic> userInfo = jsonDecode(
            preferences.getString(ConfigSharedPreferences.userInfo) ?? '{}')
        as Map<String, dynamic>;

    if (fcmToken!.isNotEmpty) {
      updateToken(userInfo["user_name"].toString(), fcmToken);
    }
  }

  Future<void> updateToken(String username, String token) async {
    Map<String, dynamic> body = {
      'username': username,
      'token': token,
    };

    var response = await http.post(Uri.parse(Api.tokenUpdate), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] == 1) {
        print(token);
      }
    }
  }

  Future<void> notifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo = jsonDecode(
            preferences.getString(ConfigSharedPreferences.userInfo) ?? '{}')
        as Map<String, dynamic>;

    var response = await http.get(
        Uri.parse("${Api.notifications}/${userInfo["user_name"].toString()}"));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      setState(() {
        count = responseBody["count"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      return Theme(
          data: theme.copyWith(
              colorScheme: theme.colorScheme
                  .copyWith(secondary: customTheme.Primary.withAlpha(40))),
          child: Scaffold(
            backgroundColor: FxAppTheme.theme.scaffoldBackgroundColor,
            body: SizedBox.expand(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                  setState(() {});
                },
                children: const <Widget>[
                  HomeScreen(),
                  NotificationScreen(),
                  ProfileScreen()
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: FxAppTheme.theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.only(bottom: 20, right: 32, left: 32),
              child: BottomBarFloating(
                items: [
                  TabItem(
                    icon: Icons.home,
                    title: 'home'.tr(),
                  ),
                  TabItem(
                    icon: Icons.notifications,
                    title: 'notifications'.tr(),
                    count: (count > 0)
                        ? FxContainer.rounded(
                            paddingAll: 4,
                            color: theme.colorScheme.primary,
                            child: Center(
                                child: FxText.bodySmall(
                              '$count',
                              color: theme.colorScheme.onPrimary,
                              fontSize: 8,
                            )),
                          )
                        : Container(),
                  ),
                  TabItem(
                    icon: Icons.account_box,
                    title: 'profile'.tr(),
                  ),
                ],
                backgroundColor: FxAppTheme.theme.cardColor,
                color: FxAppTheme.theme.primaryColor,
                colorSelected: customTheme.Primary,
                indexSelected: currentIndex,
                paddingVertical: 16,
                borderRadius: BorderRadius.circular(10),
                onTap: (index) => setState(() {
                  setState(() => currentIndex = index);
                  _pageController.jumpToPage(index);
                  notifications();
                }),
              ),
            ),
          ));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
