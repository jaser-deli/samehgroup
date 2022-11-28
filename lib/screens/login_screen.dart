import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/config/screens.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  late DateTime currentBackPressTime;
  bool _obscurePassword = true;

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void login(String mobile, String password) async {
    Map<String, dynamic> body = {"username": mobile, "password": password};

    var response = await http.post(Uri.parse(Api.login), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      loginSuccessful(responseBody["data"]);
    } else {
      Fluttertoast.showToast(
          msg: 't_u_or_p_in_or_in'.tr(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: const Color(0xff656565),
          timeInSecForIosWeb: 1);
      return;
    }
  }

  Future loginSuccessful(Map<String, dynamic> response) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (response["token"].toString().isNotEmpty) {
      // save token in SharedPreferences
      preferences.setString(ConfigSharedPreferences.token, response["token"]);

      // save User Info in SharedPreferences
      preferences.setString(
          ConfigSharedPreferences.userInfo, jsonEncode(response["user_info"]));
      // go to Main Screen
      Navigator.pushNamedAndRemoveUntil(
          context, Screens.main.value, (Route<dynamic> route) => false);
    } else {
      Fluttertoast.showToast(
          msg: 't_is_a_p_w_t_s'.tr(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: const Color(0xff656565),
          timeInSecForIosWeb: 1);
      return;
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: 'p_t_b_b_to_e'.tr(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: const Color(0xff656565),
          timeInSecForIosWeb: 1);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          body: WillPopScope(
            onWillPop: onWillPop,
            child: ListView(
              padding: FxSpacing.fromLTRB(24, 70, 24, 0),
              children: [
                Image.asset(
                  "./assets/images/logo.png",
                  height: 200,
                ),
                FxSpacing.height(16),
                Center(
                  child: FxText.headlineSmall('login'.tr(),
                      color: customTheme.Primary, fontWeight: 600),
                ),
                FxSpacing.height(32),
                FxTextField(
                  controller: _usernameController,
                  cursorColor: customTheme.Primary,
                  readOnly: false,
                  style: TextStyle(color: customTheme.Primary),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.person, color: customTheme.Primary),
                      prefixIconColor: customTheme.Primary,
                      hintText: 'username'.tr(),
                      hintStyle: TextStyle(color: customTheme.Primary),
                      fillColor: customTheme.Primary.withAlpha(40),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      counter: const Offstage(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: customTheme.Primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: customTheme.Primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0))),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                  ],
                ),
                FxSpacing.height(24),
                TextFormField(
                  controller: _passwordController,
                  cursorColor: customTheme.Primary,
                  readOnly: false,
                  style: TextStyle(color: customTheme.Primary),
                  maxLines: 1,
                  decoration: InputDecoration(
                      suffixIcon: InkWell(
                          onTap: _togglePassword,
                          child: Icon(
                            (_obscurePassword)
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: customTheme.Primary,
                          )),
                      prefixIcon: Icon(Icons.lock, color: customTheme.Primary),
                      prefixIconColor: customTheme.Primary,
                      hintText: 'password'.tr(),
                      hintStyle: TextStyle(color: customTheme.Primary),
                      fillColor: customTheme.Primary.withAlpha(40),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      counter: const Offstage(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: customTheme.Primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: customTheme.Primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0))),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _obscurePassword,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                  ],
                ),
                FxSpacing.height(16),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: FxButton.text(
                //       onPressed: () {
                //         Navigator.of(context, rootNavigator: true).push(
                //           MaterialPageRoute(
                //               builder: (context) => ForgotPasswordScreen()),
                //         );
                //       },
                //       padding: FxSpacing.zero,
                //       splashColor: customTheme.Primary.withAlpha(40),
                //       child: FxText.labelMedium("Forgot Password?",
                //           color: customTheme.Primary)),
                // ),
                // FxSpacing.height(16),
                FxButton.medium(
                    borderRadiusAll: 8,
                    onPressed: () {
                      formValidator();
                    },
                    backgroundColor: customTheme.Primary,
                    child: FxText.labelLarge(
                      'login'.tr(),
                      color: customTheme.OnPrimary,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Future formValidator() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty) {
      Fluttertoast.showToast(
          msg: 'p_e_username'.tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: const Color(0xff656565),
          timeInSecForIosWeb: 1);
      return;
    }

    if (password.isEmpty) {
      Fluttertoast.showToast(
          msg: 'p_e_password'.tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: const Color(0xff656565),
          timeInSecForIosWeb: 1);
      return;
    }

    login(username, password);
  }
}
