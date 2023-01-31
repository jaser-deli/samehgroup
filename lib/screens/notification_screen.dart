import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/config/config_shared_preferences.dart';
import 'package:samehgroup/screens/notification_item_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future notifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> userInfo = jsonDecode(
            preferences.getString(ConfigSharedPreferences.userInfo) ?? '{}')
        as Map<String, dynamic>;

    var response = await http.get(
        Uri.parse("${Api.notifications}/${userInfo["user_name"].toString()}"));

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      return responseBody["data"];
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
        child: SafeArea(
          child: Scaffold(
              body: FutureBuilder(
            future: notifications(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: (snapshot.data as List).length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                      builder: (_) => NotificationItemScreen(
                                            id: (snapshot.data as List)[index]
                                                    ["id"]
                                                .toString(),
                                            username: (snapshot.data
                                                as List)[index]["username"],
                                            title: (snapshot.data
                                                as List)[index]["title"],
                                            message: (snapshot.data
                                                as List)[index]["body"],
                                          )),
                                )
                                .then((_) => setState(() {}));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 12, left: 16, right: 16, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: customTheme.Primary,
                                  child: Icon(Icons.notifications,
                                      color: customTheme.OnPrimary),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                                flex: 1,
                                                child: FxText.titleSmall(
                                                    "${(snapshot.data as List)[index]["title"]}",
                                                    fontWeight: ((snapshot.data
                                                                        as List)[
                                                                    index]
                                                                ["is_read"] ==
                                                            0)
                                                        ? 700
                                                        : 500)),
                                            FxText.titleSmall(
                                                DateFormat('yy-MM-dd').format(
                                                    DateTime.parse(
                                                        (snapshot.data
                                                                as List)[index]
                                                            ["created_at"])),
                                                fontWeight: ((snapshot.data
                                                                as List)[index]
                                                            ["is_read"] ==
                                                        0)
                                                    ? 700
                                                    : 500)
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: FxText.bodyMedium(
                                                "${(snapshot.data as List)[index]["body"]}",
                                                fontWeight: ((snapshot.data
                                                                as List)[index]
                                                            ["is_read"] ==
                                                        0)
                                                    ? 700
                                                    : 500,
                                                letterSpacing: 0,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            ((snapshot.data as List)[index]
                                                        ["is_read"] ==
                                                    0)
                                                ? Icon(
                                                    Icons.circle,
                                                    size: 10,
                                                    color: customTheme.Primary,
                                                  )
                                                : Container()
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const Divider()
                      ],
                    );
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  color: customTheme.Primary,
                ),
              );
            },
          )),
        ),
      );
    });
  }
}
