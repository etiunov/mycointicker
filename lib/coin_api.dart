import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart' as rootBundle;

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
  Future<Map<String, dynamic>> getCoinData() async {
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
List<double> changeValueList = [];

List<dynamic> investmentList = [];

Map<String, dynamic> cryptoPrices = {};
Map<String, dynamic> cryptoChange = {};
Map<String, dynamic> cryptoInvestment = {};
Map<String, dynamic> cryptoIds = {};
Map<String, dynamic> cryptoNames = {};
Map<String, dynamic> cryptoSymbols = {};

class CoinIdNameSymbol {
  Future getName() async {
    String requestURL = 'https://api.coinpaprika.com/v1/tickers/';
    http.Response response = await http.get(Uri.parse(requestURL));
    var rateData = jsonDecode(response.body);
    int num = 0;
    for (int i = num; i < 30; i++) {
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
    for (String id in idList) {
      JsonDecoder jsonDecoder =
          JsonDecoder("$coinPaprikaAPI$id?quotes=$selectedCurrency");
      var coinData = await jsonDecoder.getCoinData();
      var ids = await coinData["id"];
      cryptoIds[id] = ids;
      var names = await coinData["name"];
      cryptoNames[id] = names;
      var symbols = await coinData["symbol"];
      cryptoSymbols[id] = symbols;

      var price = await coinData["quotes"]["$selectedCurrency"]["price"];
      cryptoPrices[id] = price.toStringAsFixed(0);
      pricesList.add(price.toStringAsFixed(2));
      var percentChange24h =
          coinData["quotes"]["$selectedCurrency"]["percent_change_24h"];
      cryptoChange[id] = percentChange24h;
      changeList.add(percentChange24h.toStringAsFixed(2));
      changeValueList.add(percentChange24h);

      var percentChange1y =
          coinData["quotes"]["$selectedCurrency"]["percent_change_1y"];
      cryptoInvestment[id] = percentChange1y;
      investmentList.add(percentChange1y.toStringAsFixed(0));
    }
    // var toInt = pricesList.map((e) => e.toInt()).toList();
    // print(pricesList);
    // print(changeList);
    // print(investmentList);

    // print(cryptoIds);
    // print(cryptoNames);
    // print(cryptoSymbols);
    // var toInte = changeList.map((e) => e.toInt()).toList();
    print(changeValueList);
  }
}

class CryptoData {
  final String name, symbol, currency;

  CryptoData({
    this.name,
    this.symbol,
    this.currency,
  });

  factory CryptoData.fromJson(Map<String, dynamic> data) {
    return CryptoData(
      name: data["name"],
      symbol: data["symbol"],
      currency: data["quotes"],
    );
  }
}
