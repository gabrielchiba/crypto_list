
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'src/api/cmc_api.dart';

void main() async{
  // Load api key from .env file in root
  await dotenv.load(fileName: ".env");
  List currencies = await getCurrencies();
  runApp(new MaterialApp(
    title: 'Cryptocurrencies List',
    theme: ThemeData(
      primaryColor: Colors.black,
    ),
    home: new CryptoList(currencies, 'Cryptocurrencies List'),
  ));
}

class CryptoList extends StatefulWidget {
  final List cryptocurrencies;
  final String title;
  CryptoList(this.cryptocurrencies, this.title);

  @override
  _CryptoListState createState() => _CryptoListState();
}

class _CryptoListState extends State<CryptoList>{
  // final controller = FloatingSearchBarController();
  late List cryptocurrenciesQuery;

  @override
  void initState() {
    cryptocurrenciesQuery = widget.cryptocurrencies;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Icon(Icons.panorama_photosphere_outlined),
        brightness: Brightness.dark,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blueAccent,
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildFloatingSearchBar(context),
            _buildBody(),
          ],
        ),
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _buildFAB(),
          ]
      )
    );
  }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  Widget _buildFAB() {
    return new FloatingActionButton(
      backgroundColor: Colors.indigo,
      onPressed: () => _showNotification(),
      tooltip: 'Set Notification',
      child: Icon(Icons.notifications),
    );
  }

  _showNotification() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Alert Set"),
    ));
  }

  Widget _buildBody() {
    return new Container(
      // Setting the left, top, right and bottom margin respectively
      margin: const EdgeInsets.fromLTRB(8.0, 65.0, 8.0, 0.0),
      child: new Column(
        children: <Widget>[
          _getListViewWidget()
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        queryList(query);
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(

        );
      },
    );
  }

  queryList(String query) {
    cryptocurrenciesQuery = [];
    if (query.isEmpty) {
      setState(() {
        cryptocurrenciesQuery = widget.cryptocurrencies;
      });
    } else {
      for (int i = 0; i < widget.cryptocurrencies.length; ++i) {
        String cryptoName = widget.cryptocurrencies[i]['slug'];
        if (cryptoName.contains(query)) {
          setState(() {
            cryptocurrenciesQuery.add(widget.cryptocurrencies[i]);
          });
        }
      }
    }
  }

  Widget _getListViewWidget() {
    return new Flexible(
        child: new ListView.builder(
            itemCount: cryptocurrenciesQuery.length,
            itemBuilder: (context, index) {
              final Map currency = cryptocurrenciesQuery[index];
              return _getListItemWidget(currency);
            })
    );
  }

  CachedNetworkImage _getIconWidget(int currencyId) {
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

  ListTile _getListTile(Map currency) {
    return new ListTile(
      leading: _getIconWidget(currency['id']),
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

  Container _getListItemWidget(Map currency) {
    return new Container(
      child: new Card(
          child: Padding (
            padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
            child: _getListTile(currency),
          )
      ),
    );
  }
}
