import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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