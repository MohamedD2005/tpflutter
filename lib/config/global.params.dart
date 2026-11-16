import 'package:flutter/material.dart';

class GlobalParams {
  static List<Map<String, dynamic>> menus = [
    {"title": "Accueil", "icon": const Icon(Icons.home, color: Colors.blue), "route": "/home"},
    {"title": "Météo", "icon": const Icon(Icons.sunny_snowing, color: Colors.blue), "route": "/meteo"},
    {"title": "Maps", "icon": const Icon(Icons.location_on, color: Colors.blue), "route": "/maps"},
    {"title": "Contacts", "icon": const Icon(Icons.phone, color: Colors.blue), "route": "/contacts"},
    {"title": "Messenger", "icon": const Icon(Icons.messenger_outline, color: Colors.blue), "route": "/messenger"},
    {"title": "ChatBot", "icon": const Icon(Icons.android, color: Colors.blue), "route": "/chatbot"},
    {"title": "Paramètres", "icon": const Icon(Icons.settings, color: Colors.blue), "route": "/parametres"},
    {"title": "Déconnexion", "icon": const Icon(Icons.logout, color: Colors.blue), "route": "/authentification"},
  ];

  static List<Map<String, dynamic>> accueil = [
    {"title": "Météo", "icon": Icons.wb_sunny, "route": "/meteo"},
    {"title": "Maps", "icon": Icons.map, "route": "/maps"},
    {"title": "Contacts", "icon": Icons.contacts, "route": "/contacts"},
    {"title": "Messenger", "icon": Icons.chat, "route": "/messenger"},
    {"title": "ChatBot", "icon": Icons.smart_toy, "route": "/chatbot"},
    {"title": "Paramètres", "icon": Icons.settings, "route": "/parametres"},
  ];
}