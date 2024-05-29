import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

//非同期で岩手県内陸の天気を取得する
Future<String> futureJsonWeather(http.Client client) async {
  final response = await http.get(Uri.parse('https://www.jma.go.jp/bosai/forecast/data/forecast/030000.json'));

  if (response.statusCode == 200) {
    String body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = jsonDecode(body);
    return jsonResponse[0]['timeSeries'][0]['areas'][0]['weathers'][0];
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
  Future<String> futureWeather = futureJsonWeather(http.Client());

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
          child: FutureBuilder<String>(
            future: futureWeather,
            builder: (context,snapshot) {
              if (snapshot.hasData) {
                return Text('今日の岩手県内陸の天気: ${snapshot.data}');
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
