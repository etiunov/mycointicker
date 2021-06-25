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

class CoinIdNameSymbol {
  Future getName() async {
    String requestURL = 'https://api.coinpaprika.com/v1/tickers/';
    http.Response response = await http.get(Uri.parse(requestURL));
    var rateData = jsonDecode(response.body);
    int num = 0;
    for (int i = num; i < 9; i++) {
      var id = rateData[i]["id"].toString();
      var name = rateData[i]["name"].toString();
      var symbol = rateData[i]["symbol"].toString();
      idList.add(id);
      namesList.add(name);
      symbolsList.add(symbol);
    }
    print(idList);
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
          coinData["quotes"]["$selectedCurrency"]["percent_change_7d"];
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
