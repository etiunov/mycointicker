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
import 'home_screen.dart';
import 'wallet_screen.dart';
import 'rate_screen.dart';
import 'rate_card.dart';

class WalletCard extends StatelessWidget {
  final double width, height;
  final String coinName, imageName;
  final Color firstColor, secondColor;
  final int coinIndex;

  const WalletCard({
    Key key,
    this.width,
    this.height,
    this.coinName,
    this.firstColor,
    this.secondColor,
    this.imageName,
    this.coinIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        heightFactor: 0.25,
        alignment: Alignment.center,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: GestureDetector(
              onTap: () {
                print('Card tapped $coinIndex');
              },
              child: Container(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.asset('images/$imageName'),
                      ),
                    ),
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.30),
                                  blurRadius: 30),
                            ],
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              tileMode: TileMode.clamp,
                              colors: [firstColor, secondColor],
                            ),
                          ),
                          // width: 200.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$coinName',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.0,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$coinName',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.0,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
