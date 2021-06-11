import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'coin_api.dart';
import 'dart:core';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CoinIdNameSymbol coinIdNameSymbol = CoinIdNameSymbol();
  RateData rateData = RateData();
  String selectedCurrency = 'USD';
  // var btcUiRate = '--', ethUiRate = '--', ltcUiRate = '--';
  bool ifWaiting = false;
  var prices, names;

  @override
  void initState() {
    super.initState();
    loadCoinDataToUI();
  }

  Map<String, String> coinValues = {};
  Future<void> loadCoinDataToUI() async {
    ifWaiting = true;
    try {
      var coinNames = await coinIdNameSymbol.getName();
      var coinPrices = await rateData.getRateData(selectedCurrency);
      ifWaiting = false;
      setState(() {
        coinValues = coinPrices;
        names = coinNames;
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
            icon: Icon(CupertinoIcons.square_stack_3d_up_fill),
            label: 'Wallet'),
        BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar), label: 'Coins'),
      ]),
      tabBuilder: (context, index) {
        return (index == 0)
            ? CupertinoTabView(builder: (context) => HomePage())
            : CoinDetails(
                selectedCurrency: selectedCurrency,
              );
        CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: (index == 0) ? Text('Home') : Text('Rates'),
                ),
                child: CupertinoButton(
                  child: Center(
                    child: Text(
                      'This is tab $index',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .actionTextStyle
                          .copyWith(fontSize: 32.0),
                    ),
                  ),
                  onPressed: () {
                    // Navigator.of(context).push(
                    //   CupertinoPageRoute(builder: (context) {
                    //     return CoinDetails();
                    //   }),
                    // );
                  },
                ));
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Column makeCard() {
    List<RateCard> rateCardsList = [];
    for (var name in namesList) {
      rateCardsList.add(
        RateCard(
          coinSymbol: cryptoSymbols[name],
          coinRate: cryptoPrices[name],
          // selectedCurrency: widget.selectedCurrency,
          coinName: name,
          coinChange: null,
        ),
      );
    }
    return Column(
      children: rateCardsList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              automaticallyImplyTitle: false,
              backgroundColor: Colors.transparent,
              largeTitle: Row(
                children: [
                  Text(
                    'Wallet',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .actionTextStyle
                        .copyWith(fontSize: 32.0),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      CupertinoIcons.add_circled_solid,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              makeCard(),
            ])),
          ],
        ),
      ),
    );
  }
}

class CoinDetails extends StatefulWidget {
  var selectedCurrency;
  CoinDetails({@required this.selectedCurrency});

  @override
  _CoinDetailsState createState() => _CoinDetailsState();
}

class _CoinDetailsState extends State<CoinDetails> {
  RateData rateData = RateData();
  List<Widget> cryptoData = [];

  // Widget _loadCryptoData(int index) {
  //   List<Widget> coinsData = [];
  //   for(String coin in namesList){
  //   coinsData.add(Card(
  //     color: Colors.blue[100 * (index % 9)],
  //     child: ListTile(
  //       title: Text(symbolsList[index]),
  //       subtitle: Text(namesList[index]),
  //       trailing: Text(cryptoPrices[coin]),
  //     ),
  //   ));
  //   setState(() {
  //     cryptoData = coinsData;
  //   });
  //   return cryptoData;
  // }}

  Future<void> loadRate(selectedCurrency) async {
    try {
      var coinPrices = await rateData.getRateData(selectedCurrency);
      setState(() {
        // coinPrices;
      });
    } catch (error) {
      print(error);
    }
  }

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
        onSelectedItemChanged: (selectedIndex) {
          setState(() {
            widget.selectedCurrency = currenciesList[selectedIndex];
          });
        },
        children: pickerItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoPageScaffold(
        child: idList.length > 1
            ? CustomScrollView(
                slivers: [
                  CupertinoSliverNavigationBar(
                    // trailing: Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Icon(
                    //     CupertinoIcons.add,
                    //     color: Colors.black,
                    //   ),
                    // ),
                    // automaticallyImplyTitle: false,
                    backgroundColor: Colors.transparent,
                    largeTitle: Row(
                      children: [
                        Text(
                          'Rates',
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .actionTextStyle
                              .copyWith(fontSize: 32.0),
                        ),
                        Spacer(),
                        CupertinoButton(
                          child: Text(
                            '${widget.selectedCurrency}',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .actionTextStyle
                                .copyWith(fontSize: 18.0),
                          ),
                          onPressed: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return CupertinoActionSheet(
                                  title: Text('Select currency'),
                                  actions: [
                                    CupertinoActionSheetAction(
                                      child: iOsPicker(),
                                      onPressed: () {
                                        setState(() {
                                          // rateData.getRateData(
                                          //     widget.selectedCurrency);
                                          loadRate(widget.selectedCurrency);
                                        });
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                  cancelButton: CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Done"),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  CupertinoSliverRefreshControl(onRefresh: () async {
                    await loadRate(widget.selectedCurrency);
                  }),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 3 / 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Card(
                          color: Colors.blue[100 * (index % 9)],
                          child: ListTile(
                            title: Text(
                              symbolsList[index],
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(namesList[index]),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(pricesList[index]),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: changeValueList[index] > 0
                                          ? Colors.green
                                          : Colors.redAccent),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                        top: 4.0,
                                        bottom: 4.0),
                                    child: Text(
                                      '${changeList[index]}%',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {},
                            // dense: false,
                          ),
                        );
                      },
                      childCount: idList.length,
                    ),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}

class RateCard extends StatelessWidget {
  final String coinName, selectedCurrency, coinRate;
  final List coinSymbol;
  final double coinChange;

  const RateCard(
      {Key key,
      this.coinName,
      this.selectedCurrency,
      this.coinRate,
      this.coinChange,
      this.coinSymbol})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$coinSymbol'),
        subtitle: Text('$coinName'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('$coinRate'),
            Text('$coinChange%'),
          ],
        ),
      ),
    );
  }
}

// class RateCard extends StatefulWidget {
//   final String coinName, selectedCurrency, coinRate, coinSymbol;
//   final double coinChange;
//
//   const RateCard({Key key, this.coinName, this.selectedCurrency, this.coinRate, this.coinChange, this.coinSymbol}) : super(key: key);
//
//   @override
//   _RateCardState createState() => _RateCardState();
// }
//
// class _RateCardState extends State<RateCard> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(symbolsList[index]),
//       subtitle: Text(namesList[index]),
//       trailing: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Text('222'),
//           Text('222'),
//           Text('222'),
//         ],
//       ),
//     );
//   }
// }
