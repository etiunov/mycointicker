import 'dart:core';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'wallet_card.dart';
import 'abstracted_classes.dart';
import 'coin_api.dart';

class HomePage extends StatefulWidget {
  final Map newCoin;

  const HomePage({this.newCoin});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CoinIdNameSymbol coinIdNameSymbol = CoinIdNameSymbol();
  RateData rateData = RateData();
  String newCoin;
  String selectedCurrency = 'USD';
  Map<String, String> coinValues = {};
  bool isWaiting = false;
  double appleCashBalance = 2125.78;
  double appleCashBalanceUpdated;

  List<String> addedCoinList = [
    'Litecoin',
    'Ethereum',
  ];
  List<double> coinBalanceList = [
    15.47,
    7.89,
  ];

  @override
  void initState() {
    super.initState();
    appleCashBalanceUpdated = appleCashBalance;
    Map receivedCoin = widget.newCoin;
    print('This is wallet screen $receivedCoin');
    addReceivedCoin(receivedCoin);
  }

  void addReceivedCoin(Map receivedCoin) {
    if (receivedCoin != null) {
      setState(() {
        addedCoinList.add(receivedCoin["coinName"].toString());
        coinBalanceList
            .add(double.parse(receivedCoin["amountToTrade"].toString()));
        appleCashBalanceUpdated = appleCashBalance -
            double.parse(receivedCoin["totalFee"].toString());
      });
    }
  }

  double _getTotalBalance() {
    var sum;
    setState(() {
      sum = coinBalanceList.reduce((value, element) => value + element);
    });

    return sum;
  }

  void addToWallet(coinName) {
    addedCoinList.add(coinName);
    print(addedCoinList);
  }

  Color getRandomCardColor() {
    const List colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.black,
      Colors.blueGrey,
    ];
    Random random = new Random();
    int index = random.nextInt(5);
    return colors[index];
  }

  List<String> images = [
    'ltc.png',
    'eth.png',
    'btc.png',
  ];

  Column coinsContainer() {
    List<WCard> walletCards = [];
    for (var coin in addedCoinList) {
      walletCards.add(
        WCard(
          firstColor: getRandomCardColor(),
          secondColor: getRandomCardColor(),
          coinName: coin,
          imageName: addedCoinList.lastIndexOf(coin),
          coinIndex: addedCoinList.indexOf(coin),
          coinsList: addedCoinList,
          coinBalance: coinBalanceList[addedCoinList.lastIndexOf(coin)],
        ),
      );
    }
    return Column(
      children: walletCards,
    );
  }

  Column cardContainer() {
    List<CCard> cardCards = [];
    cardCards.add(
      CCard(
        cardBalance: appleCashBalanceUpdated,
        cardName: null,
        cardNumber: null,
        cardId: null,
      ),
    );

    return Column(
      children: cardCards,
    );
  }

  void _addCoinCupertinoBottom() {
    var coinName;
    var amount;
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 300,
                  child: CupertinoFormSection(
                    children: [
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          onFieldSubmitted: (value) {
                            coinName = value;
                            // setState(() {
                            //
                            // });
                            print(coinName);
                          },
                          placeholder: 'Enter coin name',
                        ),
                        prefix: Icon(CupertinoIcons.bitcoin_circle_fill),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          onFieldSubmitted: (money) {
                            amount = money;
                            // setState(() {
                            //
                            // });
                          },
                          placeholder: 'Enter amount',
                        ),
                        prefix: Icon(CupertinoIcons.money_dollar),
                      ),
                    ],
                  ),
                ),
              ),
              onPressed: () {},
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                if (coinName != null) {
                  addToWallet(coinName);
                  coinBalanceList.add(double.parse(amount));
                }
              });
              print(coinBalanceList);
            },
            child: Text("Add"),
          ),
        );
      },
    );
  }

  // LoadFancyData loadFancyData = LoadFancyData();
  // @override
  // void initState() {
  //   loadFancyData.loadFancy();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              border: Border(bottom: BorderSide.none),
              stretch: true,
              backgroundColor: Colors.transparent,
              largeTitle: Row(
                children: [
                  Text(
                    'Wallet',
                    style: TextStyle(fontSize: 32.0, color: Colors.black),
                  ),
                  Spacer(),
                  CupertinoButton(
                    onPressed: () {
                      print("pressed");
                      _addCoinCupertinoBottom();
                    },
                    child: Icon(
                      CupertinoIcons.add_circled_solid,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: false,
              floating: true,
              delegate: Delegate(
                maxE: 140.0,
                minE: 140.0,
                delegateChild: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 18.0, right: 18.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Mark to Market:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                          Spacer(),
                          Text(
                            '\$ ${_getTotalBalance().toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  coinsContainer(),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: 100.0,
                  ),
                  cardContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
