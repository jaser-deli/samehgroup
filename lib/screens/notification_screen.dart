import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(
          colorScheme: theme.colorScheme
              .copyWith(secondary: customTheme.Primary.withAlpha(40))),
      child: SafeArea(
        child: Scaffold(
          body: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: 1,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => MailContentScreen()));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 12, left: 16, right: 16, bottom: 12),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              child: FxText(
                                "N",
                                color: theme.colorScheme.onPrimary,
                              ),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            child: FxText.titleSmall("name",
                                                fontWeight: false ? 500 : 650)),
                                        FxText.titleSmall("25 May",
                                            fontWeight: false ? 500 : 650)
                                      ],
                                    ),
                                    FxText.bodyMedium("message",
                                        fontWeight: false ? 500 : 650,
                                        letterSpacing: 0)
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
