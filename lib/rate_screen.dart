import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mycointicker/rate_chart.dart';
import 'coin_api.dart';
import 'dart:core';
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'wallet_screen.dart';
import 'rate_screen.dart';
import 'home_screen.dart';
import 'rate_card.dart';
import 'abstracted_classes.dart';
import 'constants.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

class CoinDetails extends StatefulWidget {
  @override
  _CoinDetailsState createState() => _CoinDetailsState();
}

class _CoinDetailsState extends State<CoinDetails> {
  CoinIdNameSymbol coinIdNameSymbol = CoinIdNameSymbol();
  RateData rateData = RateData();

  String selectedCurrency = 'USD';
  bool isWaiting = false;
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  List<List<FlSpot>> sumList = [];

  @override
  void initState() {
    super.initState();
    loadCoinDataToUI();
  }

  //Currency selector
  Widget iOsPicker() {
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(
        Text(currency),
      );
    }
    return SizedBox(
      height: 160,
      child: CupertinoPicker(
        itemExtent: 32.0,
        onSelectedItemChanged: (value) async {
          selectedCurrency = currenciesList[value];
          setState(() {});
          print(selectedCurrency);
        },
        children: pickerItems,
      ),
    );
  }

  //Main data
  Future<void> loadCoinDataToUI() async {
    isWaiting = true;
    try {
      await coinIdNameSymbol.getName();
      var coinPrices = await rateData.getRateData(selectedCurrency);
      await rateData.loadDates();
      await rateData.chunkHistory();
      await loadRates();

      isWaiting = false;
      setState(() {
        coinPrices;
      });
    } catch (error) {
      print(error);
    }
    // print(coinValues);
  }

  //CupertinoSliverRefreshControl
  Future<void> refreshCoinData() async {
    isWaiting = true;
    try {
      var coinPrices = await rateData.getRateData(selectedCurrency);
      isWaiting = false;
      setState(() {
        coinPrices;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<List<FlSpot>> loadRates() async {
    for (var chunk in chunkedHistoryList) {
      List<FlSpot> spots1 = await List.generate(chunk.length, (index) {
        return FlSpot(index.toDouble(), chunk[index].toDouble());
      });
      sumList.add(spots1);
    }
  }

  // var chunkedHistoryMap = await chunkedHistoryList.asMap();
  // print(chunkedHistoryMap);

  @override
  void dispose() {
    super.dispose();
    loadCoinDataToUI();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoPageScaffold(
        child: idList.length > 1
            ? CustomScrollView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      return Future<void>.delayed(Duration(seconds: 2))
                        ..then<void>((_) {
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            refreshCoinData();
                          });

                          print('refreshed');
                        });
                    },
                  ),
                  CupertinoSliverNavigationBar(
                    border: Border(bottom: BorderSide.none),
                    stretch: true,
                    backgroundColor: Colors.white,
                    largeTitle: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Coins',
                              style: mainPageHeader,
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: Delegate(
                      delegateChild: Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 18.0,
                            top: 8.0,
                            right: 18.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      print('Tapped');
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) {
                                          return CupertinoActionSheet(
                                            title: Text(
                                                'Select number of coins to display'),
                                            actions: [
                                              CupertinoActionSheetAction(
                                                child: Container(
                                                    height: 200.0,
                                                    child: Text('SlideBar')),
                                                onPressed: () {
                                                  setState(() {});
                                                },
                                              )
                                            ],
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                              onPressed: () async {
                                                setState(() {
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                });
                                              },
                                              child: Text("Select"),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.withOpacity(0.2),
                                            width: 1.0),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(18.0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            top: 8.0,
                                            bottom: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '+/- Coins',
                                              style: pickerStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              width: 1.0),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(18.0),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0,
                                              right: 16.0,
                                              top: 8.0,
                                              bottom: 8.0),
                                          child: Text(
                                            '$selectedCurrency',
                                            style: pickerStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) {
                                          return CupertinoActionSheet(
                                            title: Text('Select currency'),
                                            actions: [
                                              CupertinoActionSheetAction(
                                                child: iOsPicker(),
                                                onPressed: () async {
                                                  var newRates = await rateData
                                                      .getRateData(
                                                          selectedCurrency);

                                                  setState(() {
                                                    newRates;
                                                    Navigator.pop(
                                                      context,
                                                    );
                                                  });
                                                },
                                              )
                                            ],
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                              onPressed: () async {
                                                var newRates =
                                                    await rateData.getRateData(
                                                        selectedCurrency);

                                                setState(() {
                                                  newRates;
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                });
                                              },
                                              child: Text("Select"),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'COIN',
                                    style: marketListHeader,
                                  ),
                                  Text(
                                    '7 DAYS CHANGE',
                                    style: marketListHeader,
                                  ),
                                  Text(
                                    'PRICE',
                                    style: marketListHeader,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      maxE: 100,
                      minE: 100,
                    ),
                  ),
                  SliverSafeArea(
                    top: false,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  '${symbolsList[index]}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('${idList[index]}'),
                                trailing: SizedBox(
                                  width: 220.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: LineChart(
                                            LineChartData(
                                                lineTouchData: LineTouchData(
                                                  enabled: false,
                                                ),
                                                lineBarsData: [
                                                  LineChartBarData(
                                                    spots: sumList[index],
                                                    isCurved: true,
                                                    colors: gradientColors,
                                                    dotData:
                                                        FlDotData(show: false),
                                                    belowBarData: BarAreaData(
                                                        show: true,
                                                        colors: gradientColors
                                                            .map((e) =>
                                                                e.withOpacity(
                                                                    0.10))
                                                            .toList()),
                                                  ),
                                                ],
                                                titlesData:
                                                    FlTitlesData(show: false),
                                                gridData:
                                                    FlGridData(show: false),
                                                borderData:
                                                    FlBorderData(show: false)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${pricesList[index].toString()}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4.0,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                8.0,
                                              ),
                                              color: double.parse(
                                                          changeList[index]
                                                              .toString()) >
                                                      0
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 4.0,
                                                bottom: 4.0,
                                              ),
                                              child: Text(
                                                '${changeList[index]}%',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: idList.length,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
