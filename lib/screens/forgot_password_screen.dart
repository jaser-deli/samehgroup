import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import 'main_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(
          colorScheme: theme.colorScheme
              .copyWith(secondary: customTheme.Primary.withAlpha(40))),
      child: Scaffold(
        body: ListView(
          padding: FxSpacing.fromLTRB(24, 100, 24, 0),
          children: [
            Image.asset(
              "./assets/images/logo.png",
              height: 200,
            ),
            FxSpacing.height(16),
            FxText.headlineSmall(
              "Forgot Password",
              color: customTheme.Primary,
              fontWeight: 800,
              textAlign: TextAlign.center,
            ),
            FxSpacing.height(32),
            FxTextField(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              autoFocusedBorder: true,
              textFieldStyle: FxTextFieldStyle.outlined,
              textFieldType: FxTextFieldType.email,
              filled: true,
              fillColor: customTheme.Primary.withAlpha(40),
              enabledBorderColor: customTheme.Primary,
              focusedBorderColor: customTheme.Primary,
              prefixIconColor: customTheme.Primary,
              labelTextColor: customTheme.Primary,
              cursorColor: customTheme.Primary,
            ),
            FxSpacing.height(32),
            FxButton.block(
                borderRadiusAll: 8,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
                backgroundColor: customTheme.Primary,
                child: FxText.labelLarge(
                  "Forgot Password",
                  color: customTheme.OnPrimary,
                )),
          ],
        ),
      ),
    );
  }
}
