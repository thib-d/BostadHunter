import 'dart:math';

import 'package:flutter/material.dart';
//import 'package:webdriver/io.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:io' as io;
//import 'package:dio/adapter_browser.dart';
//import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
//import 'package:dio_cookie_manager/dio_cookie_manager.dart';
//import 'package:cookie_jar/cookie_jar.dart';
//import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cron/cron.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:requests/src/cookie.dart' show CookieJar, Cookie;
import 'package:webview_flutter/src/webview.dart' show CookieManager;

import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:requests/requests.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
//import 'package:latlong/latlong.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
//import 'package:scroll_to_index/scroll_to_index.dart';

//Hemhunter

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp(
      items: List<ListItem>.generate(
        3,
        (i) => i % 6 == 0
            ? HeadingItem('Heading $i')
            : MessageItem('Sender $i', 'Message body $i'),
      ),
    ));
  });
}

class MyApp extends StatelessWidget {
  //const MyApp({Key? key}) : super(key: key);
  const MyApp({super.key, required this.items});
  final List<ListItem> items;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bostad Hunter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BostadHunter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class House {
  final String AnnonsId;
  final String Kommun;
  final String Url;
  final String Hyra;
  final String AnnonseradTill;
  final String Rank;
  final String Stadsdel;
  final String KanAnmalaIntresse;
  final String KoordinatLongitud;
  final String KoordinatLatitud;
  var fields;

  House({
    final this.AnnonsId = "nope",
    final this.Kommun = "nope",
    final this.Url = "nope",
    final this.Hyra = "nope",
    final this.AnnonseradTill = "nope",
    final this.Rank = "nope",
    final this.Stadsdel = "nope",
    final this.KanAnmalaIntresse = "yess",
    final this.KoordinatLatitud = "nope",
    final this.KoordinatLongitud = "nope",
    this.fields = "none",
  });

  String getLatLntString() {
    return KoordinatLatitud + "," + KoordinatLongitud;
  }

  int getIntRank() {
    String s;
    int idx;
    List parts;
    int myRank = 0;

    if (Rank == "None" || Rank == "nope") {
      return 9999;
    } else {
      s = Rank;
      idx = s.indexOf(" ");
      parts = [s.substring(0, idx).trim(), s.substring(idx + 1).trim()];

      myRank = int.parse(parts[0]);
      return myRank;
    }
  }

  String getPosition() {
    return "999999";
  }

  factory House.fromJson(Map<String, dynamic> json) {
    Map<String, String> map1 = {}; //todo check value

    json.forEach((key, value) {
      if (value.runtimeType == "".runtimeType) {
        map1[key] = value;
      } else {
        map1[key] = value.toString();
      }
    });

    if (map1.containsKey("Rank")) {
    } else {
      map1['Rank'] = "nope";
    }
    ;
    return House(
      fields: map1,
      AnnonsId: map1['AnnonsId']!,
      Kommun: map1['Kommun']!,
      Url: map1['Url']!,
      Hyra: map1['Hyra']!,
      AnnonseradTill: map1['AnnonseradTill']!,
      Stadsdel: map1['Stadsdel']!,
      Rank: map1['Rank']!,
      KanAnmalaIntresse: map1["KanAnmalaIntresse"]!,
      KoordinatLongitud: map1["KoordinatLongitud"]!,
      KoordinatLatitud: map1["KoordinatLatitud"]!,
    );
  }
}

/*
Future<MultiHouse> create_multihouse(var _controller) async {
  _controller.loadUrl("https://bostad.stockholm.se/Lista/Details?aid=205596");

  var value = await _controller.webViewController.runJavascriptReturningResult('document.getElementById("knapp_logga_in").innerText');
  MultiHouse multi = new MultiHouse();
      House h = House();
      //h.test = value;
      multi.add_house(h);  
      House p = House();
      //p.test = "kkkk";
      multi.add_house(p);  
  return multi;
}
*/

Future<House> getHouse(
    var _controller, House house, _MyHomePageState classe) async {
  String url = house.Url;
  //_controller.loadUrl("https://bostad.stockholm.se/"+url);
  var r = await Requests.get("https://bostad.stockholm.se/" + url);
  r.raiseForStatus();
  String body = r.content();
  var document = parse(body);
  String value = "None";
  List values = document.getElementsByClassName("house-counter");

  if (values.isEmpty) {
    print("No rank" + house.AnnonsId);
  } else {
    value = values[0].text;
  }
  // await  _controller.runJavascriptReturningResult('document.getElementsByClassName("house-counter")[0].textContent');
  if (value.contains(" av ")) {
  } else {
    //value = "None";
  }

  Map<String, dynamic> map1 = house.fields;
  map1["Rank"] = value;
  House h = House.fromJson(map1);
  return h;
}

Future<List<House>> fetchAllHouse(_MyHomePageState classe) {
  return fetchAllHouse2(classe).then((value) {
    value.sort((a, b) {
      return a.getIntRank().compareTo(b.getIntRank());
    });

    return value;
  });
}

Future<List<House>> fetchAllHouse2(_MyHomePageState classe) async {
  List<House> myhouses = [];
  classe._controller.loadUrl("https://bostad.stockholm.se");
  var cookieManager = WebviewCookieManager();
  List mycookies =
      await cookieManager.getCookies("https://bostad.stockholm.se");
  String mycookies2 = "";
  for (var element in mycookies) {
    mycookies2 = mycookies2 + element.name + '=' + element.value + ",";
  }
  ;
  //String mycookies = await classe._controller.webViewController.runJavascriptReturningResult('document.cookie');
  String url = "https://bostad.stockholm.se/Lista/AllaAnnonser";
  String hostname = Requests.getHostname(url);
  // Set cookies using [CookieJar.parseCookiesString]
  var cookies = CookieJar.parseCookiesString(mycookies2);
  Requests.setStoredCookies(hostname, cookies);

  var r = await Requests.get(url);

  r.raiseForStatus();
  dynamic json = r.json();
  House h;
  int i = 0;

  for (var jhouse in json) {
    i = i + 1;
    h = House.fromJson(jhouse);
    //print("fetchAllHouse2;;"+h.AnnonsId+h.KanAnmalaIntresse.toString());
    if (h.KanAnmalaIntresse == false || h.KanAnmalaIntresse == "false") {
      continue;
    }
    ;
    myhouses.add(h);
  }
  print("Fallhouse2:" + myhouses.length.toString());
  return myhouses;
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

Marker closestMarker(List<Marker> markers, LatLng myMarker) {
  Marker best = markers[0];
  double bestDistance = 1000000;
  LatLng latlngMarker;
  double distance;
  for (Marker element in markers) {
    latlngMarker = element.point;
    distance = calculateDistance(latlngMarker.latitude, latlngMarker.longitude,
        myMarker.latitude, myMarker.longitude);
    if (distance <= bestDistance) {
      best = element;
      bestDistance = distance;
    }
  }
  return best;
}

Color getColorRank(int rang) {
  Color color = Colors.blueAccent;
/*
Bettew 0 10   green
10 40  blue
40 grey


*/
  color = Colors.green;

  if (rang < 0) {
    color = Color.fromARGB(255, 208, 208, 41);
  }
  ;

  if (rang > 10) {
    color = Colors.blue;
  }
  ;
  if (rang > 40) {
    color = Colors.grey;
  }
  ;

  return color;
}

Marker createMarker(String lat, String lng, int rang, bool selected) {
  LatLng point = LatLng(double.parse(lat), double.parse(lng));
  Color color = getColorRank(rang);
  if (selected) {
    color = Colors.red;
  }
  return Marker(
    point: point,
    width: 60,
    height: 60,
    builder: (context) => Icon(
      Icons.pin_drop,
      size: 60,
      color: color,
    ),
  );
}

void fetchHouses(var _controller, _MyHomePageState classe) {
  fetchHouses2(_controller, classe).then((myhouses) {
    print("oading all the houses Done");
    myhouses.sort((a, b) => a.getIntRank().compareTo(b.getIntRank()));
    classe.messageButton = "Refresh" + myhouses.length.toString();

    for (House house2 in myhouses) {
      MessageItem i = MessageItem(house2.Stadsdel + " : " + house2.Kommun,
          house2.Rank + " / Rent " + house2.Hyra);
      classe.items.add(i);
      classe._markers.add(createMarker(house2.KoordinatLatitud,
          house2.KoordinatLongitud, house2.getIntRank(), false));
      classe.setState(() {});
    }
    ;
    classe.setState(() {});
  });
}

Future<List<House>> fetchHouses2(
    var _controller, _MyHomePageState classe) async {
  String url = "";
  DateTime now = new DateTime.now();
  DateTime dt2;
  House house2;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  classe.messageButton = "Loading please wait .....";
  var allhouses = await fetchAllHouse(classe);
  classe.messageButton =
      "Loading all the houses (" + allhouses.length.toString() + ")";
  print("Loading all the houses (" + allhouses.length.toString() + ")");
  await Future.forEach(allhouses, (house) async {
    house as House;
    var dateGood = DateTime.parse(house.AnnonseradTill).compareTo(now) > 0;
    var kommungood = house.Kommun == "Stockholm" || true;
    var NoneRank = house.Rank.toString().contains("None");
    var houseValid = dateGood && kommungood && NoneRank == false;
    //print(house.AnnonsId.toString()+house.AnnonseradTill.toString()+"Loading the super house"+house.toString()+dateGood.toString()+kommungood.toString()+hasRank.toString());
    if (prefs.containsKey('Status' + house.AnnonsId)) if (prefs
            .getInt("Status${house.AnnonsId}") ==
        0) {
      houseValid = false;
      print("ignore the invalid House...");
    }
    if (houseValid) {
      //print("Loading thr house"+house.toString());
      url = house.Url;
      //classe.messageButton = "Loading the houses...";
      classe.messageButton = "Loading all the houses please wait...";
      classe.setState(() {});
      house2 = await getHouse(_controller, house, classe);
      classe.myhouses.add(house2);
      //print("I add the house "+house2.AnnonsId.toString());
      classe.messageButton = "Loading all the houses please wait.";
      classe.setState(() {});
    } else {
      prefs.setInt('Status' + house.AnnonsId, 0).then((bool success) {});
      print('set invalid: ' + 'Status' + house.AnnonsId);
    }
    ;
  }); //end for ecach
  print("fetchHouses2:" + classe.myhouses.length.toString());

  classe.messageButton = "Refresh";
  classe.setState(() {});
  return classe.myhouses;
}

void bankIdDone(var _controller, _MyHomePageState classe, var context) {
  _controller
      .runJavascriptReturningResult(
          'document.getElementsByClassName("header-navigation-list")[0].textContent')
      .then((String value) {
    if (value.contains("Sidor")) {
      classe.messageButton = "Loading...";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Loading please wait...')));

      classe.setUpCron(_controller, classe);
      classe._height = 10;
      fetchHouses(_controller, classe);
    } else {
      print(value);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please loging on the website above (LOGGA IN)')));
    }
  });
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<ListItem> ads = [];
  //Future<WebDriver> driver = createDriver();
  String msg = "";
  List<House> myhouses = [];
  String messageButton = "Click here after you log in with bank ID";

  final PopupController _popupController = PopupController();
  MapController _mapController = MapController();
  double _zoom = 7;
  LatLng? centre = LatLng(59.22243419235046, 17.9388507481);
  final List<LatLng> _latLngList = [
    LatLng(13, 77.5),
    LatLng(13.02, 77.51),
    LatLng(13.05, 77.53),
    LatLng(13.055, 77.54),
    LatLng(13.059, 77.55),
    LatLng(13.07, 77.55),
    LatLng(13.1, 77.5342),
    LatLng(13.12, 77.51),
    LatLng(13.015, 77.53),
    LatLng(13.155, 77.54),
    LatLng(13.159, 77.55),
    LatLng(13.17, 77.55),
  ];
  List<Marker> _markers = [];

/*
List
*/
  double _ITEM_HEIGHT = 70.0;
  ScrollController _scrollController = new ScrollController();

/*
Maps
*/

  String selectedBostadtext = "";

  void _refresh() {
    //driver = createDriver();

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  //final Future<MultiHouse> _calculation = fetchHouses2(_controller,isPaused);

  var _controller;
  double _height = 600;
  var toto;
  var isPaused = true;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int _selectedIndex = 0;
  var items = List<ListItem>.generate(
    0,
    (i) => i % 6 == 0
        ? HeadingItem('Heading $i')
        : MessageItem('Sender $i', 'Message body $i'),
  );

  _launchUrl(index, houses, controller) async {
    String url = "https://bostad.stockholm.se" + myhouses[index].Url;
    controller.loadUrl(url);
    //launch(url);

    Clipboard.setData(new ClipboardData(text: url)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL copied to your clipboard !')));
    });
  }

  void markerClicked(LatLng point) {
    if (_markers.isEmpty) {
      return;
    }
    Marker bestMarker = closestMarker(_markers, point);

    House h;
    bool selected = false;
    _selectedIndex = 5;

    _scrollController.jumpTo(50);

    for (House element in myhouses) {
      if (element.getLatLntString() ==
          bestMarker.point.latitude.toString() +
              "," +
              bestMarker.point.longitude.toString()) {
        _controller.loadUrl("https://bostad.stockholm.se/" + element.Url);
        _markers = [];
        for (House house2 in myhouses) {
          selected = false;
          if (house2.AnnonsId == element.AnnonsId) {
            selected = true;
          }
          _markers.add(createMarker(house2.KoordinatLatitud,
              house2.KoordinatLongitud, house2.getIntRank(), selected));
        }
        selectedBostadtext = element.Stadsdel +
            ":" +
            element.Kommun +
            " => " +
            element.Rank +
            " / Rent " +
            element.Hyra;
        _controller.loadUrl("https://bostad.stockholm.se/" + element.Url);

        Clipboard.setData(new ClipboardData(
                text: "https://bostad.stockholm.se/" + element.Url))
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('URL copied to your clipboard !')));
        });

        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //AndroidWebView.platform = AndroidWebView();

    //if (Platform.isAndroid) {
    //  WebView.platform = AndroidWebView();
    //}
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: _height,
              child: WebView(
                onWebViewCreated: (controller) {
                  this._controller = controller;
                  //controller.loadUrl("https://github.com/");
                  controller
                      .loadUrl("https://bostad.stockholm.se/Minasidor/login/")
                      .then((value) {
                    setState(() {
                      Future.delayed(const Duration(milliseconds: 600), () {
                        bankIdDone(_controller, this, context);
                        print("Bank ID Done");
                      });
                    });
                  });
                },
                onPageFinished: (url) {
                  /*
                        _controller.getHeight().then((double height) {
                          setState(() {
                            //_height = height;
                          });
                        });
                        */
                },
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.blue,
              ),
              onPressed: () => {
                setState(() {
                  bankIdDone(_controller, this, context);
                  print("Bank ID Done");
                })
              },
              child: Text('' + messageButton),
            ),
            Expanded(
              // wrap in Expanded
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  // swPanBoundary: LatLng(13, 77.5),
                  // nePanBoundary: LatLng(13.07001, 77.58),
                  center: centre,
                  //bounds: LatLngBounds.fromPoints(_latLngList),
                  zoom: _zoom,
                  onTap: (tapPosition, point) => {
                    setState(() {
                      _height = 300;
                      markerClicked(point);
                    })
                  },

                  plugins: [
                    MarkerClusterPlugin(),
                  ],
                  //onTap: (_) => _popupController.hidePopup(),
                ),
                layers: [
                  TileLayerOptions(
                    minZoom: 2,
                    maxZoom: 18,
                    backgroundColor: Colors.black,
                    // errorImage: ,
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),

                  /*    
                    MarkerClusterLayerOptions(
                      maxClusterRadius: 190,
                      disableClusteringAtZoom: 20,
                      size: Size(50, 50),
                      fitBoundsOptions: FitBoundsOptions(
                        padding: EdgeInsets.all(50),
                      ),
                      markers: _markers,


                      builder: (context, markers) {
                        return Container(
                          alignment: Alignment.center,
                          decoration:
                              BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: Text('${markers.length}'),
                        );
                      },
                    ),
                    */
                  MarkerLayerOptions(markers: _markers)
                ],
              ),
            ),
            Text(
                'In green when you are in the top 10, Blue top 40, and Grey after'),
            Text(selectedBostadtext),
            Expanded(
              // wrap in Expanded
              child: ListView.builder(
                // Let the ListView know how many items it needs to build.
                controller: _scrollController,

                itemCount: items.length,
                // Provide a builder function. This is where the magic happens.
                // Convert each item into a widget based on the type of item it is.
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: item.buildTitle(context),
                    subtitle: item.buildSubtitle(context),
                    selected: index == _selectedIndex,
                    onTap: () {
                      _height = 300;
                      setState(() {});
                      _launchUrl(index, myhouses, _controller);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.

      bottomNavigationBar:  BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "List")
        ],
            ),
    */
    );
  }

  void checkNewHouse(List<House> houses) {
// Create storage
    final storage = new FlutterSecureStorage();
    int alert = 0;
    String s;
    int idx;
    List parts;
    int myRank = 0;

    storage.readAll().then((allValues) {
      for (House house in houses) {
        if (allValues.containsKey("alert-" + house.AnnonsId.toString())) {
          print("already imformed about" + house.AnnonsId);
        } //already alerted
        else {
          s = house.Rank;
          myRank = house.getIntRank();
          if (myRank < 20) {
            alert = 1;
            storage.write(
                key: "alert-" + house.AnnonsId.toString(), value: "mydate");
          }
        }
      } //end for

      if (alert == 1) {
        _showNotification(
            "You have a new appartement where you are in the top 20");
      } else {
        print("No new houses");
      }
    });
  }

  Future _showNotification(String msg) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'BostadHunter', 'BostadHuntername',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Bostad hunder, new bostad where in you are in the top 20',
      msg,
      platformChannelSpecifics,
      payload: 'Please check the app Bostad Hunder for more information',
    );
  }

  Future onSelectNotification(var payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Your Notification Detail"),
          content: Text("Payload : oooooo"),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _markers = _latLngList
        .map((point) => Marker(
              point: point,
              width: 60,
              height: 60,
              builder: (context) => Icon(
                Icons.pin_drop,
                size: 60,
                color: Colors.blueAccent,
              ),
            ))
        .toList();
    super.initState();
  }

  setUpCron(var _controller, _MyHomePageState classe) {
    var cron = new Cron();
    cron.schedule(new Schedule.parse('*/1 * * * *'), () async {
      fetchHouses2(_controller, classe);
      checkNewHouse(classe.myhouses);
    });
  }
} //end state

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}
