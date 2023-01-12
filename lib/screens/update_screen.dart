import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutx/widgets/button/button.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:ota_update/ota_update.dart';
import 'package:provider/provider.dart';
import 'package:samehgroup/config/style.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  double valuePercent = 0.5;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  Future<void> update() async {
    // RUN OTA UPDATE
    // START LISTENING FOR DOWNLOAD PROGRESS REPORTING EVENTS
    try {
      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      OtaUpdate()
          .execute(
              'http://ls.samehgroup.com:8081/LiveSales_old_new/public/storage/apps/pda.apk')
          .listen(
        (OtaEvent event) {
          // setState(() => currentEvent = event);
          if (valuePercent != -1) {
            setState(() {
              valuePercent = double.parse(event.value.toString());
              setState(() {});
            });
          }
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          bottomNavigationBar: Container(
            height: 50,
            margin: paddingHorizontal.add(paddingVerticalMedium),
            child: FxButton.medium(
                borderRadiusAll: 8,
                onPressed: () async {
                  // await update();
                },
                backgroundColor: customTheme.Primary,
                child: FxText.labelLarge(
                  'تحميل'.tr(),
                  color: customTheme.OnPrimary,
                )),
          ),
          body: WillPopScope(
            onWillPop: () async {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
              return false;
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('النسخة هذا غير مستقرة الرجاء تنزيل النسخة الجديدة'.tr(),
                      style: theme.textTheme.subtitle1),
                  SizedBox(
                    height: 20,
                  ),
                  (valuePercent > 0.5)
                      ? Container(
                          padding: EdgeInsets.all(10),
                          child: LinearPercentIndicator(
                            //leaner progress bar
                            width: 210,
                            //width for progress bar
                            animation: true,
                            //animation to show progress at first
                            animationDuration: 1000,
                            lineHeight: 30.0,
                            //height of progress bar
                            leading: Padding(
                              //prefix content
                              padding: EdgeInsets.only(right: 15),
                              child: Text("left content"), //left content
                            ),
                            trailing: Padding(
                              //sufix content
                              padding: EdgeInsets.only(left: 15),
                              child: Text("right content"), //right content
                            ),
                            percent: 0.3,
                            // 30/100 = 0.3
                            center: Text("30.0%"),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            //make round cap at start and end both
                            progressColor: Colors.redAccent,
                            //percentage progress bar color
                            backgroundColor: Colors
                                .orange[100], //background progressbar color
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
