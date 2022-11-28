import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/screens/home_screen.dart';
import 'package:samehgroup/screens/notification_screen.dart';
import 'package:samehgroup/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutx/flutx.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late PageController _pageController;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
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
              children: <Widget>[
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
              }),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
