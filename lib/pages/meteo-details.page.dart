import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../menu/drawer.widget.dart';

class MeteoDetailsPage extends StatefulWidget {
  final String ville;
  const MeteoDetailsPage(this.ville, {super.key});

  @override
  State<MeteoDetailsPage> createState() => MeteoDetailsPageState();
}

class MeteoDetailsPageState extends State<MeteoDetailsPage> {
  Map<String, dynamic>? meteoData;

  @override
  void initState() {
    super.initState();
    getMeteoData(widget.ville);
  }

  Future<void> getMeteoData(String ville) async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$ville&appid=c109c07bc4df77a88c923e6407aef864";
    try {
      final res = await http.get(Uri.parse(url));
      if (!mounted) return;
      setState(() {
        meteoData = json.decode(res.body) as Map<String, dynamic>;
      });
    } catch (err) {
      debugPrint('$err');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherData = meteoData;
    return Scaffold(
      appBar: AppBar(title: Text('Page Meteo Details ${widget.ville}')),
      drawer: const MyDrawer(),
      body: weatherData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: weatherData['list'] == null
                  ? 0
                  : weatherData['list'].length,
              itemBuilder: (context, index) {
                var weatherItem = weatherData['list'][index];
                var weatherMain = weatherItem['weather'][0]['main'];
                var dt = weatherItem['dt'];
                var tempKelvin = weatherItem['main']['temp'];
                var tempCelsius = (tempKelvin - 273.15).round();

                return Card(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                "images/${weatherMain.toString().toLowerCase()}.png",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('E-dd/MM/yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(dt * 1000),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(dt * 1000))} | $weatherMain",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "$tempCelsius °C",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}