import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/api.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class NotificationItemScreen extends StatefulWidget {
  final String id;
  final String username;
  final String title;
  final String message;

  const NotificationItemScreen(
      {Key? key,
      required this.id,
      required this.username,
      required this.title,
      required this.message})
      : super(key: key);

  @override
  State<NotificationItemScreen> createState() => _NotificationItemScreenState();
}

class _NotificationItemScreenState extends State<NotificationItemScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;

    update(widget.id, widget.username);
  }

  void update(String id, String username) async {
    Map<String, dynamic> body = {
      'id': id,
      'username': username,
    };

    var response =
        await http.post(Uri.parse("${Api.notifications}/update"), body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      if (responseBody["data"] == 1) {
        print(responseBody);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      return Scaffold(
        appBar: AppBar(
          title: FxText.headlineSmall('notice_details'.tr(),
              color: FxAppTheme.theme.primaryColor, fontWeight: 500),
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 0.0),
                )
              ],
              color: customTheme.Primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Container(
          color: theme.backgroundColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Center(
                          child: FxText.titleMedium("${widget.title}",
                              fontWeight: 600))),
                ],
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: FxText.bodyMedium("${widget.message}", fontWeight: 500),
              ),
            ],
          ),
        ),
      );
    });
  }
}
