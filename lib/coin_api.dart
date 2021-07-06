import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' as rootBundle;

// 'https://api.coinpaprika.com/v1/tickers/btc-bitcoin?quotes=EUR,BTC';

const coinHttpAPI = 'https://rest.coinapi.io/v1/exchangerate';
const apiKey = 'CB8A010A-71A9-4AE6-B9E9-B07800018C7E';
const coinPaprikaAPI = 'https://api.coinpaprika.com/v1/tickers/';
const List<String> currenciesList = [
  'USD',
  'EUR',
  'PLN',
  'KRW',
  'GBP',
  'CAD',
  'JPY',
  'RUB',
  'TRY',
  'NZD',
  'AUD',
  'CHF',
  'UAH',
  'HKD',
  'SGD',
  'NGN',
  'PHP',
  'MXN',
  'BRL',
  'THB',
  'CLP',
  'CNY',
  'CZK',
  'DKK',
  'HUF',
  'IDR',
  'ILS',
  'INR',
  'MYR',
  'NOK',
  'PKR',
  'SEK',
  'TWD',
  'ZAR',
  'VND',
  'BOB',
  'COP',
  'PEN',
  'ARS',
  'ISK',
];

class JsonDecoder {
  JsonDecoder(this.url);
  final String url;
  Future<dynamic> getCoinData() async {
    http.Response response = await http.get(
      Uri.parse(url),
    );
    response.statusCode == 200
        ? response.body
        : print('Error ${response.statusCode}');
    return jsonDecode(response.body);
  }
}

class Coins {}

List<String> idList = [];
List<String> namesList = [];
List<String> symbolsList = [];
List<dynamic> pricesList = [];
List<dynamic> changeList = [];
List<dynamic> changeValueList = [];

List<dynamic> investmentList = [];

Map<String, dynamic> cryptoPrices = {};
Map<dynamic, dynamic> cryptoChange = {};
Map<String, dynamic> cryptoInvestment = {};
Map<String, dynamic> cryptoIds = {};
Map<String, dynamic> cryptoNames = {};
Map<String, dynamic> cryptoSymbols = {};

List<dynamic> daysList = [];
List<dynamic> historyList = [];
List<dynamic> chunkedHistoryList = [];
List<double> serviceFeesList = [];

class CoinIdNameSymbol {
  List<String> idListNot = [];
  List<String> namesListNot = [];
  List<String> symbolsListNot = [];

  Future getName() async {
    String requestURL = 'https://api.coinpaprika.com/v1/tickers/';
    http.Response response = await http.get(Uri.parse(requestURL));
    var rateData = jsonDecode(response.body);
    int num = 0;
    for (int i = num; i < 9; i++) {
      var id = rateData[i]["id"].toString();
      var name = rateData[i]["name"].toString();
      var symbol = rateData[i]["symbol"].toString();
      idListNot.add(id);
      namesListNot.add(name);
      symbolsListNot.add(symbol);
    }
    idList = idListNot;
    namesList = namesListNot;
    symbolsList = symbolsListNot;
    print(namesList);
  }
}

class RateData {
  Future getRateData(String selectedCurrency) async {
    var prices = [];
    for (String id in idList) {
      JsonDecoder jsonDecoder =
          JsonDecoder("$coinPaprikaAPI$id?quotes=$selectedCurrency");
      var coinData = await jsonDecoder.getCoinData();
      // var ids = await coinData["id"];
      // cryptoIds[id] = ids;
      // var names = await coinData["name"];
      // cryptoNames[id] = names;
      // var symbols = await coinData["symbol"];
      // cryptoSymbols[id] = symbols;

      var price = await coinData["quotes"]["$selectedCurrency"]["price"];
      // cryptoPrices[id] = price.toStringAsFixed(3);

      prices.add(double.parse(price.toStringAsFixed(3)));

      var percentChange24h =
          coinData["quotes"]["$selectedCurrency"]["percent_change_24h"];
      // cryptoChange[id] = double.parse(percentChange24h.toStringAsFixed(2));

      changeList.add(percentChange24h.toStringAsFixed(2));
      // changeValueList.add(percentChange24h);

      var percentChange1y =
          coinData["quotes"]["$selectedCurrency"]["percent_change_1y"];
      // cryptoInvestment[id] = percentChange1y;
      investmentList.add(percentChange1y.toStringAsFixed(0));
    }
    pricesList = prices;
    // print(cryptoPrices);
  }

  Future<void> generateServiceFee() async {
    var updatedFees;
    List<double> serviceFeesListNot = [];
    for (var i in pricesList) {
      updatedFees = (i * 0.0149 + i * 0.0005);
      if (updatedFees > 1.0) {
        serviceFeesListNot.add(
            double.parse((i = (i * 0.0149 + i * 0.0005)).toStringAsFixed(4)));
      } else {
        serviceFeesListNot.add(updatedFees = 0.99);
      }
    }
    serviceFeesList = serviceFeesListNot;
    print(serviceFeesList);
    Map<String, dynamic> serviceFeeMap =
        Map.fromIterables(symbolsList, serviceFeesList);
    print(serviceFeeMap);
  }

  Future<void> loadDates() async {
    daysList.clear();
    var today = new DateTime.now();
    var day = new DateFormat('d');
    for (var i = 7; i > 0; i--) {
      var addDays = today.subtract(Duration(days: i));
      var formatted = day.format(addDays);
      daysList.add(double.parse(formatted));
    }
  }

  Future<dynamic> getHistoricalData() async {
    var dummyHistory = [];
    var today = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDateNow = formatter.format(today);
    var subtractSevenDays = today.subtract(const Duration(days: 7));
    String formattedDateAgo = formatter.format(subtractSevenDays);
    try {
      for (var id in idList) {
        for (var i = 0; i < 7; i++) {
          JsonDecoder jsonDecoder = JsonDecoder(
              'https://api.coinpaprika.com/v1/coins/$id/ohlcv/historical?start=$formattedDateAgo&end=$formattedDateNow');
          final List<dynamic> loadHistoryData = await jsonDecoder.getCoinData();
          var rate = loadHistoryData[i]["open"];
          dummyHistory.add(double.parse(rate.toStringAsFixed(3)));
        }
      }
      historyList = dummyHistory;
      print('historyList ${historyList.length}');
      return historyList;
    } catch (e) {
      print(e);
    }
  }

  Future<void> chunkHistory() async {
    var history = await getHistoricalData();
    var chunksList = [];
    for (var i = 0; i < history.length; i += 7) {
      chunksList.add(
        history.sublist(i, i + 7 > history.length ? history.length : i + 7),
      );
    }
    chunkedHistoryList = chunksList;
    print('chunkedHistoryList ${chunkedHistoryList.length}');
    return chunksList;
  }
}

// class CoinData {
//   final String id;
//   final String name;
//   final String symbol;
//   final int rank;
//   final int circulating_supply;
//   final int total_supply;
//   final int max_supply;
//   final double beta_value;
//   final List quotes;
//
//   CoinData(
//       {this.id,
//       this.name,
//       this.symbol,
//       this.rank,
//       this.circulating_supply,
//       this.total_supply,
//       this.max_supply,
//       this.beta_value,
//       this.quotes});
//   factory CoinData.fromJson(dynamic json) {
//     return CoinData(
//       id: json['id'],
//       name: json['name'],
//       symbol: json['symbol'],
//       rank: json['rank'],
//       circulating_supply: json['circulating_supply'],
//       total_supply: json['total_supply'],
//       max_supply: json['max_supply'],
//       beta_value: json['beta_value'],
//       quotes: parseQuotes(json['quotes']),
//     );
//   }
//
//   static List<dynamic> parseQuotes(quotesJson) {
//     List<dynamic> quotesList = List<dynamic>.from(quotesJson);
//     return quotesList;
//   }
// }
//
// class LoadFancyData {
//   static const String requestURL = 'https://api.coinpaprika.com/v1/tickers/';
//   Future<void> loadFancy() async {
//     http.Response response = await http.get(Uri.parse(requestURL));
//     // final jsonResponse = json.decode(response);
//     List<dynamic> rateData = jsonDecode(response.body);
//     CoinData coinData = CoinData.fromJson(rateData);
//     print('id: ${coinData.id}');
//   }
// }
//
// class CurrencyDetails {
//   // final double price;
//   // final double volume_24h;
//   // final double volume_24h_change_24h;
//   // final double market_cap;
//   // final double market_cap_change_24h;
//   //
//   // "price"
//   // "volume_24h"
//   // "volume_24h_change_24h"
//   // "market_cap"
//   // "market_cap_change_24h"
//   // "percent_change_15m"
//   // "percent_change_30m"
//   // "percent_change_1h"
//   // "percent_change_6h"
//   // "percent_change_12h"
//   // "percent_change_24h"
//   // "percent_change_7d"
//   // "percent_change_30d"
//   // "percent_change_1y"
//   // "ath_price"
//
// }
