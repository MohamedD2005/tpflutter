import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/global.params.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blueAccent],
              ),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 56, color: Colors.blue),
              ),
            ),
          ),
          ...(GlobalParams.menus as List).map((item) {
            return Column(
              children: [
                const Divider(height: 4, color: Colors.blue),
                ListTile(
                  title: Text(
                    '${item['title']}',
                    style: const TextStyle(fontSize: 22),
                  ),
                  leading: item['icon'],
                  trailing: const Icon(Icons.arrow_right, color: Colors.blue),
                  onTap: () async {
                    if ('${item['title']}' != "Déconnexion") {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "${item['route']}");
                    } else {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("connecte", false);
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/authentification',
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}