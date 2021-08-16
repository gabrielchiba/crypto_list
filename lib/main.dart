import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

Future<List> getCurrencies() async {
  String apiUrl = 'pro-api.coinmarketcap.com';
  String baseCoin = 'BRL';
  String limit = '100';

  final queryParameters = {
    'convert': baseCoin,
    'limit': limit,
  };

  final uri =
  Uri.https(apiUrl, '/v1/cryptocurrency/listings/latest', queryParameters);
  // Print the http request
  print(uri);

  // Get the key from env and call get method
  http.Response response = await http.get(uri,
  headers: {
    'X-CMC_PRO_API_KEY': dotenv.env['CMC_API'].toString(),
    'Accept': 'application/json'
  });

  Map<String, dynamic> map = jsonDecode(response.body);
  List<dynamic> data = map['data'];
  return data;
}

void main() async{
  // Load api key from .env file in root
  await dotenv.load(fileName: ".env");
  List currencies = await getCurrencies();
  runApp(new MaterialApp(
    home: new CryptoListWidget(currencies),
  ));
}

class CryptoListWidget extends StatelessWidget {
  final List _currencies;
  CryptoListWidget(this._currencies);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _buildBody(),
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildBody() {
    return new Container(
      // Setting the left, top, right and bottom margin respectively
      margin: const EdgeInsets.fromLTRB(8.0, 54.0, 8.0, 0.0),
      child: new Column(
        children: <Widget>[
          _getAppTitleWidget(),
          _getListViewWidget()
        ],
      ),
    );
  }

  Widget _getAppTitleWidget() {
    return new Text(
      'Cryptocurrencies',
      style: new TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24.0),
    );
  }

  Widget _getListViewWidget() {
    return new Flexible(
        child: new ListView.builder(
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final Map currency = _currencies[index];
              // print(currency['quote']['BRL']['price']);

              // Get a Color from Primary Color list
              final MaterialColor color = Colors.primaries[index % Colors.primaries.length];

              return _getListItemWidget(currency, color);
            })
    );
  }

  CircleAvatar _getIconWidget(String currencyName, MaterialColor color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: new Text(currencyName[0],
        style: TextStyle(color: Colors.white),),
    );
  }

  Text _getTitleWidget(String currencyName) {
    return new Text(
      currencyName,
      style: new TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Text _getSubtitlePriceWidget(double priceUsd) {
    String price = priceUsd.toStringAsFixed(2);
    return new Text('R\$ $price');
  }

  Text _getSubtitleLastChangeWidget(double percentChange1h) {
    String percent = percentChange1h.toStringAsFixed(2);
    return new Text('1 hour: $percent%');
  }

  ListTile _getListTile(Map currency, MaterialColor color) {
    return new ListTile(
      leading: _getIconWidget(currency['name'], color),
      title: _getTitleWidget(currency['name']),
      subtitle: Padding (
          padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getSubtitlePriceWidget(currency['quote']['BRL']['price']),
            SizedBox( height: 2.0),
            _getSubtitleLastChangeWidget(currency['quote']['BRL']['percent_change_1h']),
          ],
        ),
      ),
    );
  }

  Container _getListItemWidget(Map currency, MaterialColor color) {
    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new Card(
        child: Padding (
          padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
          child: _getListTile(currency, color),
        )
      ),
    );
  }
}

