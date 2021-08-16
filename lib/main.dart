import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

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

Future<Map> getCurrencyInfo(int id) async {
  String apiUrl = 'pro-api.coinmarketcap.com';
  String idText = id.toString();
  final queryParameters = {
    'id': idText
  };

  final uri =
  Uri.https(apiUrl, '/v1/cryptocurrency/info', queryParameters);
  // Print the http request
  print(uri);

  // Get the key from env and call get method
  http.Response response = await http.get(uri,
      headers: {
        'X-CMC_PRO_API_KEY': dotenv.env['CMC_API'].toString(),
        'Accept': 'application/json'
      });

  Map<String, dynamic> map = jsonDecode(response.body)['data'][idText];

  return map;
}

void main() async{
  // Load api key from .env file in root
  await dotenv.load(fileName: ".env");
  List currencies = await getCurrencies();
  runApp(new MaterialApp(
    home: new CryptoList(currencies),
  ));
}

class CryptoList extends StatelessWidget {
  final List _currencies;
  CryptoList(this._currencies);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _buildBody(),
      backgroundColor: Colors.blueAccent,
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

  CachedNetworkImage _getIconWidget(int currencyId, MaterialColor color) {
    return new CachedNetworkImage(
      imageUrl: "https://s2.coinmarketcap.com/static/img/coins/64x64/" + currencyId.toString() +".png",
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
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
    return new Text(
        'R\$ $price',
        style: new TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Row _getSubtitleLastChangeWidget(double percentChange1h) {
    String percent = percentChange1h.toStringAsFixed(2);
    Icon icon;
    MaterialColor color;
    if (percentChange1h >= 0) {
      color = Colors.green;
      icon = Icon(
        Icons.arrow_drop_up,
        color: Colors.green,
        size: 30.0,
      );
    } else {
      color = Colors.red;
      icon = Icon(
        Icons.arrow_drop_down,
        color: Colors.red,
        size: 30.0,
      );
    }
    return new Row (
      children: [
        icon,
        Text(
            '$percent%',
            style: TextStyle(color: color)
        ),
      ],
    );
  }

  Text _getSubtitleSymbol(String slug) {
    return new Text(slug);
  }

  ListTile _getListTile(Map currency, MaterialColor color) {
    return new ListTile(
      leading: _getIconWidget(currency['id'], color),
      title: Row (
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _getTitleWidget(currency['name']),
          _getSubtitlePriceWidget(currency['quote']['BRL']['price']),
        ],
      ),
      subtitle: Padding (
          padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _getSubtitleSymbol(currency['symbol']),
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
