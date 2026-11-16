import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home.page.dart';
import 'pages/inscription.page.dart';
import 'pages/authentification.page.dart';
import 'pages/meteo.page.dart';
import 'pages/maps.page.dart';
import 'pages/contacts.page.dart';
import 'pages/messenger.page.dart';
import 'pages/chatbot.page.dart';
import 'pages/parametres.page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final routes = {
    '/home': (context) => const HomePage(),
    '/inscription': (context) => const InscriptionPage(),
    '/authentification': (context) => const AuthentificationPage(),
    '/meteo': (context) => Meteo(),
    '/maps': (context) =>  Maps(),
    '/contacts': (context) => const Contacts(),
    '/messenger': (context) => const Messenger(),
    '/chatbot': (context) => const ChatBot(),
    '/parametres': (context) => const Parametres(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: routes,
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            bool conn = snapshot.data?.getBool('connecte') ?? false;
            if (conn) {
              return const HomePage();
            }
          }
          return const AuthentificationPage();
        },
      ),
    );
  }
}