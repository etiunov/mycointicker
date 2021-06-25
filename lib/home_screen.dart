import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'coin_api.dart';
import 'dart:core';
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'wallet_screen.dart';
import 'rate_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CoinIdNameSymbol coinIdNameSymbol = CoinIdNameSymbol();
  HomePage homePage = HomePage();
  RateData rateData = RateData();
  List<Widget> cryptoData = [];
  String selectedCurrency = 'USD';
  bool ifWaiting = false;
  Map<String, String> coinValues = {};

  @override
  void initState() {
    super.initState();
    // loadCoinDataToUI();
  }

  Future<void> loadCoinDataToUI() async {
    ifWaiting = true;
    try {
      await coinIdNameSymbol.getName();
      var coinPrices = await rateData.getRateData(selectedCurrency);
      ifWaiting = false;
      setState(() {
        coinValues = coinPrices;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: [
        BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.square_stack_3d_up_fill,
          ),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chart_bar),
          label: 'Market',
        ),
      ]),
      tabBuilder: (context, index) {
        return (index == 0)
            ? CupertinoTabView(
                builder: (context) => HomePage(),
              )
            : CoinDetails();
      },
    );
  }
}
