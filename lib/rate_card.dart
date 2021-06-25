// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'coin_api.dart';
// import 'dart:core';
// import 'dart:async';
// import 'dart:io' show Platform;
// import 'dart:math';
// import 'dart:ui';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_sticky_header/flutter_sticky_header.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/sparkcharts.dart';
// import 'home_screen.dart';
// import 'wallet_screen.dart';
// import 'rate_screen.dart';
// import 'abstracted_classes.dart';
//
// class RateCard extends StatelessWidget {
//   final String coinName, coinRate, coinSymbol;
//   final double coinChange;
//   final Future<dynamic> historyRate;
//   final List<FlSpot> spots;
//   final double maxX, minX, maxY, minY;
//
//   RateCard({
//     @required this.coinName,
//     @required this.coinRate,
//     @required this.coinChange,
//     @required this.coinSymbol,
//     @required this.historyRate,
//     @required this.spots,
//     this.maxX,
//     this.minX,
//     this.maxY,
//     this.minY,
//   });
//
//   final List<Color> gradientColors = [
//     const Color(0xff23b6e6),
//     const Color(0xff02d39a),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         child: ListTile(
//           title: Text(
//             '$coinSymbol',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           subtitle: Text(
//             '$coinName',
//           ),
//           trailing: SizedBox(
//             width: 220.0,
//             height: 50.0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: LineChart(
//                     LineChartData(
//                         maxX: daysList.length.toDouble(),
//                         minX: 0.0,
//                         maxY: maxY,
//                         minY: minY,
//                         lineTouchData: LineTouchData(
//                           enabled: false,
//                         ),
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: spots,
//                             isCurved: true,
//                             colors: gradientColors,
//                             dotData: FlDotData(show: false),
//                             belowBarData: BarAreaData(
//                                 show: true,
//                                 colors: gradientColors
//                                     .map((e) => e.withOpacity(0.3))
//                                     .toList()),
//                           ),
//                         ],
//                         titlesData: FlTitlesData(show: false),
//                         gridData: FlGridData(show: false),
//                         borderData: FlBorderData(show: false)),
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '$coinRate',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4.0,
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(
//                           8.0,
//                         ),
//                         color: double.parse(coinChange.toString()) > 0
//                             ? Colors.green
//                             : Colors.redAccent,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                           left: 8.0,
//                           right: 8.0,
//                           top: 4.0,
//                           bottom: 4.0,
//                         ),
//                         child: Text(
//                           '$coinChange%',
//                           style: TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // class MyChart extends StatefulWidget {
// //   RateCard rateCard = RateCard();
// //
// //   @override
// //   _MyChartState createState() => _MyChartState();
// // }
// //
// // class _MyChartState extends State<MyChart> {
// //   final List<Color> gradientColors = [
// //     const Color(0xff23b6e6),
// //     const Color(0xff02d39a),
// //   ];
// //   @override
// //   Widget build(BuildContext context) {
// //     return LineChart(
// //       LineChartData(
// //           maxX: 7,
// //           minX: 1,
// //           maxY: 7,
// //           minY: 1,
// //           lineTouchData: LineTouchData(
// //             enabled: false,
// //           ),
// //           lineBarsData: [
// //             LineChartBarData(
// //               spots: spots,
// //               // spots: [
// //               //   FlSpot(1, 3),
// //               //   FlSpot(2, 1),
// //               //   FlSpot(3, 3),
// //               //   FlSpot(4, 2),
// //               //   FlSpot(5, 6),
// //               //   FlSpot(6, 6),
// //               //   FlSpot(7, 6),
// //               // ],
// //               isCurved: true,
// //               colors: gradientColors,
// //               dotData: FlDotData(show: false),
// //               belowBarData: BarAreaData(
// //                   show: true,
// //                   colors:
// //                       gradientColors.map((e) => e.withOpacity(0.3)).toList()),
// //             )
// //           ],
// //           titlesData: FlTitlesData(show: false),
// //           gridData: FlGridData(show: false),
// //           borderData: FlBorderData(show: false)),
// //     );
// //   }
// // }
