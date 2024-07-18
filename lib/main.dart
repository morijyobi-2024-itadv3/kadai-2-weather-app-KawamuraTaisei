import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class WeatherData {
  final String pref;
  final String area;
  final String sky;
  final String tempHigh;
  final String tempLow;

  WeatherData({required this.pref,required this.area, required this.sky, required this.tempHigh, required this.tempLow});

  factory WeatherData.fromJson(String pref,String area, Map<String, dynamic> json) {
    return WeatherData(
      pref: pref,
      area: area,
      sky: json['sky'],
      tempHigh: json['tempHigh'],
      tempLow: json['tempLow'],
    );
  }
}

//非同期で岩手県内陸の天気を取得する
Future<Map<String, WeatherData>> futureJsonWeather(http.Client client) async {
  final response = await http.get(Uri.parse("https://5712-180-28-130-141.ngrok-free.app/v0.2/api?pref=岩手県&area=内陸"));

  if (response.statusCode == 200) {
    String body = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = jsonDecode(body);
    Map<String, WeatherData> weatherData = {
      'today': WeatherData.fromJson(jsonResponse['pref'], jsonResponse['area'], jsonResponse['today']),
      'tomorrow': WeatherData.fromJson(jsonResponse['pref'], jsonResponse['area'], jsonResponse['tomorrow']),
    };
    return weatherData;
  } else {
    throw Exception('Failed to load data');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Map<String, WeatherData>> futureWeather = futureJsonWeather(http.Client());

  @override
  void initState() {
    super.initState();
    futureWeather = futureJsonWeather(http.Client());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('天気予報アプリ'),
        ),
        body: Center(
          child: FutureBuilder<Map<String, WeatherData>>(
            future: futureWeather,
            builder: (context,snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!;
                if(data['today'] != null && data['tomorrow'] != null) {
                  var todayData = data['today']!;
                  var tomorrowData = data['tomorrow']!;
                  return Column(
                    children: [
                      Text('${todayData.pref} ${todayData.area}'),
                      Text('今日の天気: ${todayData.sky}'),
                      Text('最高気温: ${todayData.tempHigh}'),
                      Text('最低気温: ${todayData.tempLow}'),
                      Text('明日の天気: ${tomorrowData.sky}'),
                      Text('最高気温: ${tomorrowData.tempHigh}'),
                      Text('最低気温: ${tomorrowData.tempLow}'),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
