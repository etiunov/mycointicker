import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mycointicker/home_screen.dart';
import 'coin_api.dart';
import 'dart:core';
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'abstracted_classes.dart';
import 'constants.dart';
import 'package:local_auth/local_auth.dart';
import 'local_auth_api.dart';
import 'main.dart';
import 'wallet_screen.dart';

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

  List<String> _foundSymbols = [];

  @override
  void initState() {
    super.initState();
    loadCoinDataToUI();
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
      await rateData.generateServiceFee();
      _foundSymbols = symbolsList;
      isWaiting = false;
      setState(() {
        coinPrices;
      });
    } catch (error) {
      print(error);
    }
    // print(coinValues);
  }

  //Currency selector
  Widget iOsPicker() {
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(
        Text(
          currency,
          style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.normal),
        ),
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

  //The data for chart. It was a hell to understand it...
  Future<List<FlSpot>> loadRates() async {
    for (var chunk in chunkedHistoryList) {
      List<FlSpot> spots1 = await List.generate(chunk.length, (index) {
        return FlSpot(index.toDouble(), chunk[index].toDouble());
      });
      sumList.add(spots1);
    }
  }

  Future<void> _runFilter(String enteredKeyword) async {
    List<dynamic> symbolsResults = [];
    List<dynamic> priceResults = [];
    if (enteredKeyword.isEmpty) {
      symbolsResults = symbolsList;
    } else {
      symbolsResults = symbolsList
          .where((coin) =>
              coin.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    //Refresh UI
    setState(() {
      _foundSymbols = symbolsResults;
    });
  }

  void _buyCoin(
    name,
    price,
    yearChange,
    symbol,
    serviceFees,
    selectedCurrency,
  ) {
    print(name);
    print(price);
    print(yearChange);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) {
          return BuyCoin(
            name: name,
            price: price,
            yearChange: yearChange,
            symbol: symbol,
            serviceFee: serviceFees,
            currency: selectedCurrency,
          );
        },
      ),
    );
  }

  // var chunkedHistoryMap = await chunkedHistoryList.asMap();
  // print(chunkedHistoryMap);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoPageScaffold(
        child: symbolsList.length > 1
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
                        Text(
                          'Market',
                          style: mainPageHeader,
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '$selectedCurrency',
                                style: pickerStyle,
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
                                              .getRateData(selectedCurrency);
                                          setState(() {
                                            newRates;
                                            Navigator.pop(
                                              context,
                                            );
                                          });
                                        },
                                      )
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () async {
                                        var newRates = await rateData
                                            .getRateData(selectedCurrency);

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
                        ),
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
                              CupertinoSearchTextField(
                                onChanged: (value) {
                                  _runFilter(value);
                                  print('The text has changed to: $value');
                                },
                                onSubmitted: (value) {
                                  _runFilter(value);
                                  print('Submitted text: $value');
                                },
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
                                    '7 DAYS CHART',
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
                      maxE: 80,
                      minE: 80,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _foundSymbols.length > 0
                            ? ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _foundSymbols.length,
                                itemBuilder: (context, index) => Column(
                                  children: [
                                    Card(
                                      elevation: 0,
                                      key: ValueKey(_foundSymbols[index]),
                                      child: ListTile(
                                        onTap: () {
                                          _buyCoin(
                                              namesList[index],
                                              pricesList[index],
                                              investmentList[index],
                                              symbolsList[index],
                                              serviceFeesList[index],
                                              selectedCurrency);
                                        },
                                        title: Text(
                                          '${_foundSymbols[index]}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text('${namesList[index]}'),
                                        trailing: SizedBox(
                                          width: 240.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: LineChart(
                                                    LineChartData(
                                                        lineTouchData:
                                                            LineTouchData(
                                                          enabled: false,
                                                        ),
                                                        lineBarsData: [
                                                          LineChartBarData(
                                                            spots:
                                                                sumList[index],
                                                            isCurved: true,
                                                            colors:
                                                                gradientColors,
                                                            dotData: FlDotData(
                                                                show: false),
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
                                                            FlTitlesData(
                                                                show: false),
                                                        gridData: FlGridData(
                                                            show: false),
                                                        borderData:
                                                            FlBorderData(
                                                                show: false)),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                                  changeList[
                                                                          index]
                                                                      .toString()) >
                                                              0
                                                          ? Colors.green
                                                          : Colors.redAccent,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                    Divider(),
                                  ],
                                ),
                              )
                            : Center(
                                child: Text('No results found'),
                              ),
                      ],
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

class BuyCoin extends StatefulWidget {
  final double price;
  final String name;
  final String yearChange;
  final String symbol;
  final double serviceFee;
  final String currency;

  const BuyCoin(
      {this.name,
      this.price,
      this.yearChange,
      this.symbol,
      this.serviceFee,
      this.currency});

  @override
  _BuyCoinState createState() => _BuyCoinState();
}

class _BuyCoinState extends State<BuyCoin> {
  // final navigatorKey = GlobalKey<NavigatorState>();
  bool switchValue = false;
  double loss = 0.0;
  double profit = 0.0;
  int investmentAmount = 0;
  double serviceFee = 0.00000149;
  var purchaseMap = new Map();

  final LocalAuthentication auth = LocalAuthentication();
  LocalAuthApi localAuthApi = LocalAuthApi();

  @override
  void initState() {
    super.initState();
  }

  _buyCoinCupertinoBottom(
    Map purchaseDetails,
  ) {
    var thing = showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoPopupSurface(
          child: Container(
            height: 500.0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 120.0,
                        child: Text(
                          'Crypto Store',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16.0),
                        ),
                      ),
                      Spacer(),
                      CupertinoButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.normal),
                          ),
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          })
                    ],
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          height: 40.0,
                          child: Image.asset('images/paycash.jpg'),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apple Cash'.toUpperCase(),
                              style: TextStyle(),
                            ),
                            Text(
                              'balance \$2125.74'.toUpperCase(),
                            ),
                          ],
                        ),
                        Spacer(),
                        CupertinoButton(
                            child: Icon(CupertinoIcons.chevron_forward),
                            onPressed: () {}),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          child: Text(
                            'shipping'.toUpperCase(),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Container(
                          // height: 40.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('wallet'.toUpperCase()),
                              Text('flutter@udemy.com'.toUpperCase()),
                            ],
                          ),
                        ),
                        Spacer(),
                        CupertinoButton(
                            child: Icon(CupertinoIcons.chevron_forward),
                            onPressed: () {})
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          child: Text(
                            'trade'.toUpperCase(),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'coin'.toUpperCase(),
                              ),
                              Text(
                                'Trade amount'.toUpperCase(),
                              ),
                              Text(
                                'service Fee'.toUpperCase(),
                              ),
                              Text(
                                switchValue == true
                                    ? 'stop-loss'.toUpperCase()
                                    : ' ',
                              ),
                              Text(
                                switchValue == true
                                    ? 'take-Profit'.toUpperCase()
                                    : ' ',
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                'total'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                purchaseMap["coinName"].toUpperCase(),
                              ),
                              Text('\$'.toUpperCase() +
                                  purchaseMap["amountToTrade"]
                                      .toString()
                                      .toUpperCase() +
                                  ' ' +
                                  purchaseMap["selectedCurrency"]
                                      .toString()
                                      .toUpperCase()),
                              Text('\$'.toUpperCase() +
                                  purchaseMap["serviceFee"]
                                      .toString()
                                      .toUpperCase() +
                                  ' ' +
                                  purchaseMap["selectedCurrency"]
                                      .toString()
                                      .toUpperCase()),
                              Text(
                                switchValue == true
                                    ? '\$'.toUpperCase() +
                                        purchaseMap["stopLoss"]
                                            .toString()
                                            .toUpperCase()
                                    : ' ',
                              ),
                              Text(
                                switchValue == true
                                    ? '\$'.toUpperCase() +
                                        purchaseMap["takeProfit"]
                                            .toString()
                                            .toUpperCase()
                                    : ' ',
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                '\$' + purchaseMap["totalFee"].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          // bool weCheckBiometrics =
                          //     await auth.canCheckBiometrics;
                          // if (weCheckBiometrics) {
                          //   bool authenticated =
                          //       await auth.authenticateWithBiometrics(
                          //           localizedReason: 'Authenticate to buy');
                          //   print(authenticated);
                          // }

                          final isAuthenticated =
                              await LocalAuthApi.authenticate();
                          if (isAuthenticated) {
                            print('Authenticated');

                            // Navigator.of(context).pushReplacement(
                            //   MaterialPageRoute(
                            //     builder: (BuildContext context) => HomePage(),
                            //   ),
                            // );
                            // Navigator.of(context).maybePop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    HomeScreen(newCoin: purchaseMap),
                              ),
                              (Route<dynamic> route) => false,
                            );
                            // Navigator.of(context).pushReplacement(
                            //   MaterialPageRoute(
                            //     builder: (context) => MyApp(),
                            //   ),
                            // );
                          }

                          print('TouchId touched');
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 60.0,
                              child: Icon(
                                Icons.fingerprint,
                                size: 60.0,
                                color: Colors.redAccent,
                              ),
                              // Image.asset('images/touch.png'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Pay with Touch ID'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return thing;
  }

  @override
  Widget build(BuildContext context) {
    double lossInMoney = (investmentAmount * (loss / 100));
    double profitInMoney = (investmentAmount * (profit / 100));
    double serviceFee = (investmentAmount * 0.0149);
    double totalFee = investmentAmount + serviceFee;
    purchaseMap["coinName"] = widget.name;
    purchaseMap["coinPrice"] = widget.price;
    purchaseMap["serviceFee"] = serviceFee.toInt();
    purchaseMap["selectedCurrency"] = widget.currency;
    purchaseMap["amountToTrade"] = investmentAmount;
    purchaseMap["trailing"] = switchValue;
    purchaseMap["totalFee"] = totalFee.toStringAsFixed(2);
    if (switchValue) {
      purchaseMap["stopLoss"] = lossInMoney.toInt();
      purchaseMap["takeProfit"] = profitInMoney.toInt();
    } else {
      purchaseMap.remove("stopLoss");
      purchaseMap.remove("takeProfit");
    }

    return SafeArea(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          border: Border(bottom: BorderSide.none),
          middle: Text(
            'Details for ${widget.name}',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          shrinkWrap: true,
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                          color: CupertinoColors.darkBackgroundGray,
                        ),
                        width: 100.0,
                        height: 100.0,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Image.asset(
                            'images/btc.png',
                            color: Colors.white70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('YTD Change: +${widget.yearChange}%'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Current price: ${widget.price}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'Current Every Order Fee: \$${widget.serviceFee} ${widget.symbol}'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  CupertinoFormSection(
                    children: [
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          onFieldSubmitted: (moneyA) {
                            setState(() {
                              if (moneyA.isNotEmpty) {
                                investmentAmount = double.parse(moneyA).toInt();
                              } else {
                                investmentAmount = 0;
                              }
                              print(investmentAmount);
                            });
                          },
                          placeholder: 'Enter amount to trade',
                          style: TextStyle(fontSize: 16.0),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        prefix: Icon(CupertinoIcons.money_dollar),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Trailing stops'),
                          CupertinoSwitch(
                              value: switchValue,
                              onChanged: (value) {
                                setState(() {
                                  switchValue = value;
                                  // showToast();
                                });
                              }),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Trailing stops repeats the stop-loss and the take-profit orders continuously.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Visibility(
                          visible: switchValue,
                          child: Column(
                            children: [
                              Text(
                                  'Stop-loss order ${loss.toInt()}% or \$${lossInMoney.toInt()}'),
                              Container(
                                width: 300.0,
                                child: CupertinoSlider(
                                  value: loss,
                                  onChanged: (newValue) {
                                    setState(() {
                                      loss = newValue;
                                      print(loss);
                                    });
                                  },
                                  // divisions: 10,
                                  min: 0,
                                  max: 100,
                                  activeColor: Colors.redAccent,
                                ),
                              ),
                              Text(
                                  'Take-profit order ${profit.toInt()}% or \$${profitInMoney.toInt()}'),
                              Container(
                                width: 300.0,
                                child: CupertinoSlider(
                                  value: profit,
                                  onChanged: (newValue) {
                                    setState(() {
                                      profit = newValue;
                                      print(profit);
                                    });
                                  },
                                  min: 0,
                                  max: 100,
                                  activeColor: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildPurchaseButton(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '*Clicking \'Buy Now\' you agree and accept',
                                textAlign: TextAlign.center,
                              ),
                              CupertinoButton(
                                  child: Text(
                                    'Terms of Use, Domestic & international Electronic Currency Trade Regulations',
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () {
                                    print('Open terms of use');
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]))
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    var _activeColor = CupertinoColors.activeBlue;
    var _disabledColor = CupertinoColors.inactiveGray;

    return CupertinoButton(
      color: investmentAmount != 0 ? _activeColor : _disabledColor,
      child: Text(
        'Buy Now*',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      disabledColor: CupertinoColors.inactiveGray,
      onPressed: () {
        _buyCoinCupertinoBottom(purchaseMap);
        // print(purchaseMap);
      },
    );
  }
}
