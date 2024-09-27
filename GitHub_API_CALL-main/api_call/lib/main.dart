import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<String> cities = [
    'Kalasin',
    'Khon Kaen',
    'Chaiyaphum',
    'Nakhon Phanom',
    'Nakhon Ratchasima',
    'Bueng Kan',
    'Buriram',
    'Maha Sarakham',
    'Mukdahan',
    'Yasothon',
    'Loei',
    'Sakon Nakhon',
    'Surin',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 221, 221, 221),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Weather App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // ขนาดตัวอักษร (ปรับตามที่ต้องการ)
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF03a9f4), // สีพื้นหลังของ AppBar
          foregroundColor: const Color(0xFF000000), // สีตัวอักษรของ AppBar
        ),
        body: ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 5,
              child: ListTile(
                title: Text(
                  cities[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherPage(city: cities[index]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  final String city;
  const WeatherPage({Key? key, required this.city}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Future<WeatherResponse> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getData(widget.city);
  }

  Future<WeatherResponse> getData(String city) async {
    var client = http.Client();
    try {
      var response = await client.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=7f4807689d0fbf4eb807fe06196c5c0e'));
      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception("Failed to load data");
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.city,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // ขนาดตัวอักษร (ปรับตามที่ต้องการ)
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF03a9f4), // สีพื้นหลังของ AppBar
        foregroundColor: const Color(0xFF000000), // สีตัวอักษรของ AppBar
      ),
      body: Center(
        child: FutureBuilder<WeatherResponse>(
          future: weatherData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          data.name ?? "",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                'http://openweathermap.org/img/wn/${data.weather?[0].icon ?? "01d"}@2x.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Temperature: ${data.main?.temp?.toString() ?? "0.00"}°C',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Min Temp: ${data.main?.tempMin?.toString() ?? "0.00"}°C',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Max Temp: ${data.main?.tempMax?.toString() ?? "0.00"}°C',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Pressure: ${data.main?.pressure?.toString() ?? "0"} hPa',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Humidity: ${data.main?.humidity?.toString() ?? "0"}%',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sunset: ${DateTime.fromMillisecondsSinceEpoch((data.sys?.sunset ?? 0) * 1000).toLocal()}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Clouds: ${data.clouds?.all?.toString() ?? "0"}%',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Rain (last 1h): ${data.rain?.d1h?.toString() ?? "0"} mm',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class WeatherResponse {
  final String? name;
  final Main? main;
  final Sys? sys;
  final Clouds? clouds;
  final Rain? rain;
  final List<Weather>? weather;

  WeatherResponse({
    this.name,
    this.main,
    this.sys,
    this.clouds,
    this.rain,
    this.weather,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      name: json['name'],
      main: json['main'] != null ? Main.fromJson(json['main']) : null,
      sys: json['sys'] != null ? Sys.fromJson(json['sys']) : null,
      clouds: json['clouds'] != null ? Clouds.fromJson(json['clouds']) : null,
      rain: json['rain'] != null ? Rain.fromJson(json['rain']) : null,
      weather: (json['weather'] as List<dynamic>?)
          ?.map((e) => Weather.fromJson(e))
          .toList(),
    );
  }
}

class Main {
  final double? temp;
  final double? tempMin;
  final double? tempMax;
  final int? pressure;
  final int? humidity;
  final int? seaLevel;

  Main({
    this.temp,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.humidity,
    this.seaLevel,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: (json['temp'] as num?)?.toDouble(),
      tempMin: (json['temp_min'] as num?)?.toDouble(),
      tempMax: (json['temp_max'] as num?)?.toDouble(),
      pressure: json['pressure'],
      humidity: json['humidity'],
      seaLevel: json['sea_level'],
    );
  }
}

class Sys {
  final int? sunrise;
  final int? sunset;

  Sys({
    this.sunrise,
    this.sunset,
  });

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }
}

class Clouds {
  final int? all;

  Clouds({this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(
      all: json['all'],
    );
  }
}

class Rain {
  final double? d1h;

  Rain({this.d1h});

  factory Rain.fromJson(Map<String, dynamic> json) {
    return Rain(
      d1h: (json['1h'] as num?)?.toDouble(),
    );
  }
}

class Weather {
  final String? icon;

  Weather({this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      icon: json['icon'],
    );
  }
}
