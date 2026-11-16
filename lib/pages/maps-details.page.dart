import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // ولا عبر HtmlElementView لعرض Google Maps iframe
import '../menu/drawer.widget.dart';
import 'package:latlong2/latlong.dart';

class MapsDetailsPage extends StatelessWidget {
  final String latitude;
  final String longitude;
  final String ville;

  const MapsDetailsPage({
    super.key,
    this.latitude = "",
    this.longitude = "",
    this.ville = "",
  });

  @override
  Widget build(BuildContext context) {
    double lat = double.tryParse(latitude) ?? 32.9210;
    double lng = double.tryParse(longitude) ?? 10.4508;

    return Scaffold(
      appBar: AppBar(title: const Text('Page Maps Details')),
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          // عرض خريطة تفاعلية حقيقية عبر OpenStreetMap/Leaflet التي تخدم بسلاسة على الويب
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lat, lng),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.my_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat, lng),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  ville.isNotEmpty ? "Ville: $ville" : "Lat: $lat, Lng: $lng",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}