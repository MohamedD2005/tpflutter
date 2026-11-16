import 'package:flutter/material.dart';
import '../menu/drawer.widget.dart';

class Messenger extends StatelessWidget {
  const Messenger({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Météo'),
      ),
      body: const Center(
        child: Text(
          'Page Meteo',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}