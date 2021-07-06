import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:core';
import 'dart:ui';
import 'package:intl/intl.dart';

class WCard extends StatefulWidget {
  final double coinBalance;
  final String coinName;
  final Color firstColor, secondColor;
  final int coinIndex, imageName;
  final List coinsList;

  WCard({
    Key key,
    this.coinName,
    this.firstColor,
    this.secondColor,
    this.imageName,
    this.coinIndex,
    this.coinsList,
    this.coinBalance,
  });

  deleteCoin() {
    print('Card tapped ${coinsList.indexOf(coinIndex)}');
    if (coinsList.length > 1) {
      coinsList.removeAt(coinIndex);
    } else {
      print('This was the last card');
    }
  }

  @override
  _WCardState createState() => _WCardState();
}

class _WCardState extends State<WCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openCoinDetails(widget.coinBalance, widget.coinName);
        // cardDeleteDialog();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          heightFactor: 0.20,
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              width: 340.0,
              height: 200.0,
              child: Stack(
                children: [
                  ClipRRect(
                    child: Material(
                      elevation: 20.0,
                      child: AnimatedContainer(
                        child: Container(
                          width: 400,
                          child: Opacity(
                            opacity: 0.50,
                            child: Image.network(
                              'https://source.unsplash.com/random?sig=${widget.imageName}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        duration: Duration(seconds: 60),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.30),
                                blurRadius: 30),
                          ],
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.bottomRight,
                            tileMode: TileMode.clamp,
                            colors: [widget.firstColor, widget.secondColor],
                          ),
                        ),
                        // width: 200.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.coinName}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                  color: Colors.white),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${'HOLDINGS'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Colors.white60,
                                  ),
                                ),
                                Text(
                                  '${'\$${widget.coinBalance}'}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void openCoinDetails(balance, coinName) {
    Random random = new Random();
    var rndDoubles = [];
    int max = balance.toInt();
    int min = 10;
    for (var i = 0; i < 21; i++) {
      double w = random.nextDouble();
      // int q = random.nextInt(max - min) + min;
      int q = random.nextInt(max) - random.nextInt(min);
      rndDoubles.add((q + w).toStringAsFixed(2));
    }
    print(rndDoubles);
    print(balance);

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) {
          return CoinStatement(
            balance: balance,
            coinName: coinName,
            transactionsList: List.generate(
              20,
              (index) => CoinTransactions(
                  transaction: '\$ ${rndDoubles[index]}',
                  description: '$coinName balance updated'),
            ),
          );
        },
      ),
    );
  }

  void cardDeleteDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: new Text("Alert"),
          content: new Text("Delete ${widget.coinName} card? "),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                print('Alert closed');
                Navigator.pop(
                  context,
                );
              },
              isDefaultAction: true,
              child: new Text("Close"),
            ),
            CupertinoDialogAction(
              onPressed: () {
                print('Card ${widget.coinName}deleted');
                widget.deleteCoin();
                Navigator.pop(
                  context,
                );
              },
              isDefaultAction: false,
              child: new Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class CoinTransactions {
  final String transaction;
  final String description;

  CoinTransactions({this.transaction, this.description});
}

class CoinStatement extends StatelessWidget {
  final List<CoinTransactions> transactionsList;
  final String coinName;
  final double balance;

  CoinStatement({this.transactionsList, this.coinName, this.balance});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          border: Border(bottom: BorderSide.none),
          trailing: CupertinoButton(
            onPressed: () {
              print("pressed");
            },
            child: Icon(
              CupertinoIcons.delete,
              color: Colors.black,
            ),
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          shrinkWrap: true,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
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
                          child: Icon(
                            CupertinoIcons.money_dollar,
                            size: 60.0,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            '\$$balance',
                            style: TextStyle(
                                fontSize: 32.0, fontWeight: FontWeight.bold),
                          ),
                          Text(coinName),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0),
                    child: Text(
                      '${DateFormat.yMMMM().format(DateTime.now())}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                  ),
                  ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transactionsList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 0,
                            child: ListTile(
                              title: Text(transactionsList[index].description),
                              trailing:
                                  Text(transactionsList[index].transaction),
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CCard extends StatefulWidget {
  final int cardId;
  final double cardNumber;
  final String cardName;
  final double cardBalance;
  //
  CCard({this.cardNumber, this.cardName, this.cardBalance, this.cardId});

  @override
  _CCardState createState() => _CCardState();
}

class _CCardState extends State<CCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Open card details');
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            width: 340.0,
            height: 200.0,
            child: Stack(
              children: [
                ClipRRect(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/paycash.jpg'),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.2), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.30),
                          blurRadius: 30,
                        ),
                      ],
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    // width: 200.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 12.0, top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${widget.cardBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white),
                                ),
                                Text(
                                  '${'+\$3.74'}',
                                  style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
