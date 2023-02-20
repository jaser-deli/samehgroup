import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter/foundation.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({Key? key}) : super(key: key);

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
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
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      return Theme(
        data: theme.copyWith(
            colorScheme: theme.colorScheme
                .copyWith(secondary: customTheme.Primary.withAlpha(40))),
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: FxText.headlineSmall('print'.tr(),
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
              body: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() {}),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 12, left: 16, right: 16, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: customTheme.Primary,
                            child:
                                Icon(Icons.print, color: customTheme.OnPrimary),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          flex: 1,
                                          child: FxText.titleSmall("name",
                                              fontWeight: 500)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: FxText.bodyMedium(
                                          "address",
                                          fontWeight: 500,
                                          letterSpacing: 0,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
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
                  const Divider(),
                ],
              )),
        ),
      );
    });
  }
}
