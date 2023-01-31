import 'package:provider/provider.dart';
import 'package:samehgroup/extensions/string.dart';
import 'package:samehgroup/screens/destroy_screen.dart';
import 'package:samehgroup/screens/inventory_screen.dart';
import 'package:samehgroup/screens/pricing_screen.dart';
import 'package:samehgroup/screens/receiving_screen.dart';
import 'package:samehgroup/screens/return_screen.dart';
import 'package:samehgroup/screens/single_grid_item.dart';
import 'package:samehgroup/screens/transfer_from_branch_screen.dart';
import 'package:samehgroup/screens/transfer_from_store_screen.dart';
import 'package:samehgroup/theme/app_notifier.dart';
import 'package:samehgroup/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        return Container(
            padding: FxSpacing.fromLTRB(20, 0, 20, 20),
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: <Widget>[
                GridView.count(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    crossAxisCount: 2,
                    padding: FxSpacing.top(20),
                    mainAxisSpacing: 20,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    children: <Widget>[
                      SinglePageItem(
                        iconColor: customTheme.Primary,
                        title: "destroy".tr(),
                        icon: './assets/icons/paper-shredder.png',
                        navigation: const DestroyScreen(),
                      ),
                      SinglePageItem(
                        iconColor: customTheme.Primary,
                        title: "returns".tr(),
                        icon: './assets/icons/refund.png',
                        navigation: const ReturnScreen(),
                      ),
                      SinglePageItem(
                        iconColor: customTheme.Primary,
                        title: "transfer_store".tr(),
                        icon: './assets/icons/transactions.png',
                        navigation: const TransferFromStore(),
                      ),
                      SinglePageItem(
                        iconColor: customTheme.Primary,
                        title: 'transfer_branch'.tr(),
                        icon: './assets/icons/transaction.png',
                        navigation: const TransferFromBranch(),
                      ),
                      SinglePageItem(
                        iconColor: customTheme.Primary,
                        title: 'receiving'.tr(),
                        icon: './assets/icons/box.png',
                        navigation: const ReceivingScreen(),
                      ),
                      SinglePageItem(
                        iconColor: customTheme.Primary,
                        title: 'pricing'.tr(),
                        icon: './assets/icons/barcode-scanner.png',
                        navigation: const PricingScreen(),
                      ),
                      SinglePageItem(
                        iconColor: customTheme.Primary,
                        title: 'inventory'.tr(),
                        icon: './assets/icons/inventory.png',
                        navigation: const InventoryScreen(),
                      ),
                    ]),
              ],
            ));
      },
    );
  }
}
