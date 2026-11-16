import 'package:flutter/material.dart';
import '../menu/drawer.widget.dart';
import 'maps-details.page.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final villeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  @override
  void dispose() {
    villeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Maps'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: villeController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_city),
                  hintText: "Nom de ville",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const Center(
              child: Text("OU",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: latitudeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on),
                  hintText: "Latitude",
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: longitudeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on),
                  hintText: "Longitude",
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  _onGetMapsDetails(context);
                },
                child: const Text('Chercher', style: TextStyle(fontSize: 22)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onGetMapsDetails(BuildContext context) {
    String ville = villeController.text.trim();
    String latitude = latitudeController.text.trim();
    String longitude = longitudeController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsDetailsPage(
          latitude: latitude,
          longitude: longitude,
          ville: ville,
        ),
      ),
    );

    villeController.clear();
    latitudeController.clear();
    longitudeController.clear();
  }
}