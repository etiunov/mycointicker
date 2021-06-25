import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'abstracted_classes.dart';
import 'coin_api.dart';
import 'dart:core';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'wallet_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> addedCoinList = [
    'BTC',
    'ETH',
  ];
  String newCoin;
  CoinIdNameSymbol coinIdNameSymbol = CoinIdNameSymbol();
  RateData rateData = RateData();
  String selectedCurrency = 'USD';
  Map<String, String> coinValues = {};
  bool isWaiting = false;

  void addToWallet(coinName) {
    addedCoinList.add(coinName);
    print(addedCoinList);
  }

  Color getRandomCardColor() {
    List colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.black,
      Colors.tealAccent,
      Colors.blueGrey,
    ];
    Random random = new Random();
    int index = random.nextInt(6);
    return colors[index];
  }

  String getRandomImage() {
    List images = [
      'btc.png',
      'eth.png',
      'ltc.png',
    ];
    Random random = new Random();
    int index = random.nextInt(3);
    return images[index];
  }

  Column walletContainer() {
    List<WalletCard> walletCards = [];
    Size size = MediaQuery.of(context).size;
    double countWidth = size.width * 0.80;
    for (var coin in addedCoinList) {
      walletCards.add(
        WalletCard(
          firstColor: getRandomCardColor(),
          secondColor: getRandomCardColor(),
          width: countWidth,
          height: 200.0,
          coinName: coin,
          imageName: getRandomImage(),
          coinIndex: addedCoinList.indexOf(coin),
        ),
      );
    }
    return Column(
      children: walletCards,
    );
  }

  dynamic showAddCoinDialog() {
    if (Platform.isIOS) {
      return _addCoinCupertinoBottom();
    } else if (Platform.isAndroid) {
      return _addCoinMaterialBottom(context);
    }
  }

  void _addCoinMaterialBottom(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints.expand(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Enter coin name'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Container(
                            width: 300,
                            child: TextField(
                              enableSuggestions: true,
                              onSubmitted: (value) async {
                                newCoin = value;
                                Navigator.pop(context);
                                if (newCoin != null) {
                                  addToWallet(newCoin);
                                }
                              },
                            )),
                        // Spacer(),
                        TextButton(
                          child: Text(
                            'Cancel',
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          );
        });
  }

  void _addCoinCupertinoBottom() {
    var coinName;
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
                            setState(() {
                              coinName = value;
                              // if (coinName != null) {
                              //   addToWallet(coinName);
                              // }
                            });
                            print(coinName);
                          },
                          placeholder: 'Enter coin name',
                        ),
                        prefix: Text(
                          'Coin',
                        ),
                      )
                    ],
                  ),
                ),
              ),
              onPressed: () async {
                // Navigator.of(context).pop();
                // setState(() {});
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                if (coinName != null) {
                  addToWallet(coinName);
                }
              });
            },
            child: Text("Add"),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              border: Border(bottom: BorderSide.none),
              stretch: false,
              automaticallyImplyTitle: false,
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
                      setState(
                        () {
                          _addCoinCupertinoBottom();
                        },
                      );
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
                maxE: 120.0,
                minE: 120.0,
                delegateChild: Container(
                  color: Colors.transparent,
                  height: 600.0,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  walletContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
