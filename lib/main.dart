import 'dart:convert';
import 'dart:ui';

import 'package:intl/intl.dart';

import 'search.dart';
import 'models.dart';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Softtrack Погода',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Softtrack Погода'),
      routes: {
        '/search': (context) => SearchPage()
      }
    );
  }
}

class HomePage extends StatefulWidget {

  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => HomePageState();

}

class HomePageState extends State<HomePage> {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  String cityName = '';
  String cityDateTime = 'пн, 21 марта 10:33';
  var weekDayLabels = <String, String>{
    'Monday': 'пн',
    'Tuesday': 'вт',
    'Wednesday': 'ср',
    'Thursday': 'чт',
    'Friday': 'пт',
    'Saturday': 'сб',
    'Sunday': 'вс'
  };
  var monthsLabels = <int, String>{
    0: 'янв.',
    1: 'февр.',
    2: 'мар.',
    3: 'апр.',
    4: 'мая',
    5: 'июн.',
    6: 'июл.',
    7: 'авг.',
    8: 'сен.',
    9: 'окт.',
    10: 'ноя.',
    11: 'дек'
  };
  String cityTemp = '0°';
  String cityDesc = 'Ясно';
  int cityAqi = 0;
  String cityWater = '0%';
  String citySunRise = '0';
  String citySunSet = '0';
  String cityWindSpeed = '0';
  double cityCoordLat = 0.0;
  double cityCoordLon = 0.0;

  Future<CityWeatherAQIResponse> getAQI() async {
    final response = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/air_pollution?lat=${cityCoordLat}&lon=${cityCoordLon}&appid=8ced8d3f02f94ff154bc4ddb60fa72a9'));
    if (response.statusCode == 200) {
      return CityWeatherAQIResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load city weather');
    }
  }

  getCitySunRise() {
    DateTime sunRise = DateTime.fromMillisecondsSinceEpoch(int.parse(citySunRise));
    String sunRiseTime = DateFormat('hh:mm').format(sunRise);
    return sunRiseTime;
  }

  getCitySunSet() {
    DateTime sunSet = DateTime.fromMillisecondsSinceEpoch(int.parse(citySunSet));
    String sunSetTime = DateFormat('hh:mm').format(sunSet);
    return sunSetTime;
  }

  Future<CityWeatherResponse> fetchCityWeather(String cityName) async {
    final response = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=${cityName}&appid=8ced8d3f02f94ff154bc4ddb60fa72a9&units=metric'));

    if (response.statusCode == 200) {
      return CityWeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load city weather');
    }
  }

  getMyCityInfo() {
    DateTime currentDateTime = DateTime.now();
    String weekDayKey = DateFormat('EEEE').format(currentDateTime);
    var rawWeekDayLabel = weekDayLabels[weekDayKey];
    String weekDayLabel = rawWeekDayLabel.toString();
    int cityDay = currentDateTime.day;
    int monthLabelIndex = currentDateTime.month - 1;
    var rawMonthLabel = monthsLabels[monthLabelIndex];
    String monthLabel = rawMonthLabel.toString();
    int cityHours = currentDateTime.hour;
    String rawCityHours = '$cityHours';
    if (cityHours < 10) {
      rawCityHours = '0$rawCityHours';
    }
    int cityMinutes = currentDateTime.minute;
    String rawCityMinutes = '$cityMinutes';
    if (cityMinutes < 10) {
      rawCityMinutes = '0$rawCityMinutes';
    }
    setState(() {
      cityDateTime = '${weekDayLabel}, ${cityDay} ${monthLabel} ${rawCityHours}:${rawCityMinutes}';
    });
  }

  getMyCityName() async {
    return "Moscow";
  }

  @override
  void initState() {
    super.initState();
    getMyCityName();
    getMyCityInfo();
  }

  @override
  Widget build(BuildContext context) {

    getMyCityInfo();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Color.fromARGB(255, 0, 0, 0),
        flexibleSpace: Image.network(
          'https://cdn3.iconfinder.com/data/icons/flat-icons-web/40/Sun-256.png'
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Погода',
              textAlign: TextAlign.center,
            )
          ]
        ),
        toolbarHeight: 350,

        leading: TextButton(
          child: Icon(
            Icons.menu
          ),
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          }
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            child: Icon(
              Icons.add
            )
          )
        ]
      ),
      backgroundColor: Color.fromARGB(255, 200, 200, 200),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(
                15
              ),
              padding: EdgeInsets.all(
                15
              ),
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255)
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$cityName',
                            style: TextStyle(
                              fontSize: 20
                            )
                          ),
                          Text(
                            '$cityDateTime',
                            style: TextStyle(
                              color: Color.fromARGB(255, 200, 200, 200)
                            )
                          ),
                        ]
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.network(
                            'https://cdn3.iconfinder.com/data/icons/flat-icons-web/40/Sun-256.png',
                            width: 100
                          ),
                          Container(
                            child:  Text(
                              '$cityTemp',
                              style: TextStyle(
                                fontSize: 24
                              )
                            ),
                            margin: EdgeInsets.only(
                              left: 15
                            )
                          ),
                        ]
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${cityDesc == 'Clouds' ? 'Облачно' : cityDesc}'
                          ),
                          Text(
                            '$cityTemp'
                          ),
                          Text(
                            'Ощущается как $cityTemp'
                          )
                        ]
                      )
                    ]
                  ),
                  Row(
                    children: [

                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            '00:00',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 200, 200, 200)
                            )
                          ),
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                            size: 36
                          ),
                          Text(
                            '0°',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 0, 0, 0),
                              fontWeight: FontWeight.w700
                            )
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: Color.fromARGB(255, 100, 100, 255),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left: 15
                                ),
                                child: Text(
                                  '0%'
                                )
                              )
                            ]
                          )
                        ]
                      ),
                      Column(
                        children: [
                          Text(
                            '00:00',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 200, 200, 200)
                            )
                          ),
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                            size: 36
                          ),
                          Text(
                            '0°',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 0, 0, 0),
                              fontWeight: FontWeight.w700
                            )
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: Color.fromARGB(255, 100, 100, 255),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left: 15
                                ),
                                child: Text(
                                  '0%'
                                )
                              )
                            ]
                          )
                        ]
                      ),
                      Column(
                        children: [
                          Text(
                            '00:00',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 200, 200, 200)
                            )
                          ),
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                            size: 36
                          ),
                          Text(
                            '0°',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 0, 0, 0),
                              fontWeight: FontWeight.w700
                            )
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: Color.fromARGB(255, 100, 100, 255),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left: 15
                                ),
                                child: Text(
                                  '0%'
                                )
                              )
                            ]
                          )
                        ]
                      ),
                      Column(
                        children: [
                          Text(
                            '00:00',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 200, 200, 200)
                            )
                          ),
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                            size: 36
                          ),
                          Text(
                            '0°',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 0, 0, 0),
                              fontWeight: FontWeight.w700
                            )
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: Color.fromARGB(255, 100, 100, 255),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left: 15
                                ),
                                child: Text(
                                  '0%'
                                )
                              )
                            ]
                          )
                        ]
                      ),
                      Column(
                        children: [
                          Text(
                            '00:00',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 200, 200, 200)
                            )
                          ),
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                            size: 36
                          ),
                          Text(
                            '0°',
                            style: TextStyle(
                              color: Color.fromARGB(255 , 0, 0, 0),
                              fontWeight: FontWeight.w700
                            )
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: Color.fromARGB(255, 100, 100, 255),
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                    left: 15
                                  ),
                                  child: Text(
                                    '0%'
                                  )
                              )
                            ]
                          )
                        ]
                      )
                    ]
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    child: Text(
                      'Еще'
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)
                        )
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(
                          225,
                          45
                        )
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 200, 200, 200)
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      ),
                    )
                  )
                ]
              )
            ),
            Container(
              margin: EdgeInsets.all(
                15
              ),
              padding: EdgeInsets.all(
                15
              ),
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255)
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Вчера'
                      ),
                      Text(
                        '0°'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Сегодня',
                        style: TextStyle(
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              '0%'
                            )
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Icon(
                            Icons.nightlight_round,
                            color: Color.fromARGB(255, 255, 100, 0),
                          )
                        ]
                      ),
                      Text(
                        '0°'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'вторник',
                        style: TextStyle(
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              '0%'
                            )
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Icon(
                            Icons.nightlight_round,
                            color: Color.fromARGB(255, 255, 100, 0),
                          )
                        ]
                      ),
                      Text(
                        '0°'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'среда',
                        style: TextStyle(
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              '0%'
                            )
                          )
                        ]
                      ),
                      Row(
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              color: Color.fromARGB(255, 255, 100, 0),
                            ),
                            Icon(
                              Icons.nightlight_round,
                              color: Color.fromARGB(255, 255, 100, 0),
                            )
                          ]
                      ),
                      Text(
                          '0°'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'четверг',
                        style: TextStyle(
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              '0%'
                            )
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Icon(
                            Icons.nightlight_round,
                            color: Color.fromARGB(255, 255, 100, 0),
                          )
                        ]
                      ),
                      Text(
                        '0°'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'пятница',
                        style: TextStyle(
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              '0%'
                            )
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Icon(
                            Icons.nightlight_round,
                            color: Color.fromARGB(255, 255, 100, 0),
                          )
                        ]
                      ),
                      Text(
                        '0°'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'суббота',
                        style: TextStyle(
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              '0%'
                            )
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Icon(
                            Icons.nightlight_round,
                            color: Color.fromARGB(255, 255, 100, 0),
                          )
                        ]
                      ),
                      Text(
                        '0°'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'воскресенье',
                        style: TextStyle(
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              '0%'
                            )
                          )
                        ]
                      ),
                      Row(
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              color: Color.fromARGB(255, 255, 100, 0),
                            ),
                            Icon(
                              Icons.nightlight_round,
                              color: Color.fromARGB(255, 255, 100, 0),
                            )
                          ]
                      ),
                      Text(
                          '0°'
                      )
                    ]
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    child: Text(
                      'Еще'
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)
                        )
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(
                          225,
                          45
                        )
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 200, 200, 200)
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      ),
                    )
                  )
                ]
              )
            ),
            Container(
              height: 500,
              margin: EdgeInsets.all(
                15
              ),
              padding: EdgeInsets.all(
                15
              ),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255)
              ),
              child: FlutterMap(
                options: MapOptions(
                  center: latLng.LatLng(51.5, -0.09),
                  zoom: 13.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    attributionBuilder: (_) {
                      return Text("© OpenStreetMap contributors");
                    },
                  ),
                  MarkerLayerOptions(
                      markers: [
                        Marker(
                            width: 80.0,
                            height: 80.0,
                            point: latLng.LatLng(51.5, -0.09),
                            builder: (ctx) =>
                                Container(
                                    child: Icon(
                                        Icons.near_me
                                    )
                                )
                        )
                      ]
                  )
                ]
              )
            ),
            Container(
              margin: EdgeInsets.all(
                15
              ),
              padding: EdgeInsets.all(
                15
              ),
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255)
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              'УФ-индекс'
                            )
                          )
                        ]
                      ),
                      Text(
                        'Низкий'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              'Восход'
                            )
                          )
                        ]
                      ),
                      Text(
                        '${0}'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 255, 100, 0),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              'Закат'
                            )
                          )
                        ]
                      ),
                      Text(
                        getCitySunSet()
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              'Ветер'
                            )
                          )
                        ]
                      ),
                      Text(
                        '$cityWindSpeed км/ч'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              'AQI'
                            )
                          )
                        ]
                      ),
                      Text(
                        '$cityAqi'
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Color.fromARGB(255, 100, 100, 255),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 15
                            ),
                            child: Text(
                              'Влажность'
                            )
                          )
                        ]
                      ),
                      Text(
                        cityWater
                      )
                    ]
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    child: Text(
                      'Еще'
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)
                        )
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(
                          225,
                          45
                        )
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 200, 200, 200)
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  )
                ]
              )
            ),
            Container(
              margin: EdgeInsets.all(
                15
              ),
              padding: EdgeInsets.all(
                15
              ),
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_rounded,
                        color: Color.fromARGB(255, 200, 100, 255)
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Сложность дорожных условий'
                                ),
                                Text(
                                  'Нет',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700
                                  )
                                )
                              ]
                            ),
                            Divider()
                          ]
                        ),
                        width: MediaQuery.of(context).size.width - 100,
                        margin: EdgeInsets.only(
                          left: 15
                        )
                      )
                    ]
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.dirty_lens,
                        color: Color.fromARGB(255, 255, 200, 0)
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Пыльца'
                                ),
                                Text(
                                  'Нет',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700
                                  )
                                )
                              ]
                            ),
                            Divider()
                          ]
                        ),
                        width: MediaQuery.of(context).size.width - 100,
                        margin: EdgeInsets.only(
                          left: 15
                        )
                      )
                    ]
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Color.fromARGB(255, 150, 200, 0)
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Пробежка'
                                ),
                                Text(
                                  'Хорошо',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700
                                  )
                                )
                              ]
                            ),
                            Divider()
                          ]
                        ),
                        width: MediaQuery.of(context).size.width - 100,
                        margin: EdgeInsets.only(
                          left: 15
                        )
                      )
                    ]
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    child: Text(
                      'Еще'
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)
                        )
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(
                          225,
                          45
                        )
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 200, 200, 200)
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  )
                ]
              )
            )
          ]
        )
      ),
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(
            15
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.settings
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Color.fromARGB(255, 0, 0, 255),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 25
                        ),
                        child: Text(
                          'Избранное место'
                        )
                      )
                    ]
                  ),
                  Icon(
                    Icons.info_outline
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Москва',
                    style: TextStyle(
                      color: Color.fromARGB(255, 100, 100, 255),
                      fontWeight: FontWeight.w900
                    )
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: Color.fromARGB(255, 255, 100, 0),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 15
                        ),
                        child: Text(
                          '2°'
                        )
                      )
                    ]
                  )
                ]
              ),
              Divider(),
              Row(
                children: [
                  Icon(
                    Icons.add_location_rounded
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 15
                    ),
                    child: Text(
                      'Другие места'
                    )
                  )
                ]
              ),
              TextButton(
                onPressed: () {

                },
                child: Text(
                  'Управлять местами'
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(18.0)
                    )
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(
                      225,
                      45
                    )
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 200, 200, 200)
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 0, 0, 0)
                  ),
                )
              ),
              Divider(),
              Row(
                children: [
                  Icon(
                    Icons.speaker
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 15
                    ),
                    child: Text(
                      'Неправильное место'
                    )
                  )
                ]
              ),
              Row(
                children: [
                  Icon(
                    Icons.headset_mic_rounded
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 15
                    ),
                    child: Text(
                      'Свяжитесь с нами'
                    )
                  )
                ]
              ),
              Row(
                children: [
                  Icon(
                    Icons.help
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 15
                    ),
                    child: Text(
                      'Использование'
                    )
                  )
                ]
              )
            ]
          )
        ),
      ),
    );
  }
}
