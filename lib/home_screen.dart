import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:core';
import 'wallet_screen.dart';
import 'rate_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map newCoin;

  const HomeScreen({this.newCoin});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                builder: (context) => HomePage(newCoin: widget.newCoin),
              )
            : CoinDetails();
      },
    );
  }
}
