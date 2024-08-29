import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class WeatherData {
  final String sky;
  final String tempHigh;
  final String tempLow;

  WeatherData({required this.sky, required this.tempHigh, required this.tempLow});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      sky: json['sky'],
      tempHigh: json['tempHigh'],
      tempLow: json['tempLow'],
    );
  }
}

class WeatherInfo {
  final String pref;
  final String area;
  final WeatherData today;
  final WeatherData tomorrow;

  WeatherInfo({required this.pref, required this.area, required this.today, required this.tomorrow});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      pref: json['pref'],
      area: json['area'],
      today: WeatherData.fromJson(json['today']),
      tomorrow: WeatherData.fromJson(json['tomorrow']),
    );
  }
}

//非同期で岩手県内陸の天気を取得する
Future<WeatherInfo> futureJsonWeather(http.Client client) async {
  final response = await http.get(Uri.parse("https://cc54-180-28-130-141.ngrok-free.app/v0.2/api?pref=岩手県&area=内陸"));

  if (response.statusCode == 200) {
    String body = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = jsonDecode(body);
    return WeatherInfo.fromJson(jsonResponse);
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
  Future<WeatherInfo> futureWeather = futureJsonWeather(http.Client());

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
          child: FutureBuilder<WeatherInfo>(
            future: futureWeather,
            builder: (context,snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!;
                return Column(
                  children: [
                    Text('${data.pref} ${data.area}'),
                    Text('今日の天気: ${data.today.sky}'),
                    Text('最高気温: ${data.today.tempHigh}'),
                    Text('最低気温: ${data.today.tempLow}'),
                    Text('明日の天気: ${data.tomorrow.sky}'),
                    Text('最高気温: ${data.tomorrow.tempHigh}'),
                    Text('最低気温: ${data.tomorrow.tempLow}'),
                  ],
                );
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