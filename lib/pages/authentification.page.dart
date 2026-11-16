import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthentificationPage extends StatefulWidget {
  const AuthentificationPage({super.key});

  @override
  State<AuthentificationPage> createState() => _AuthentificationPageState();
}

class _AuthentificationPageState extends State<AuthentificationPage> {
  final _formKey = GlobalKey<FormState>();
  final txtLogin = TextEditingController();
  final txtPassword = TextEditingController();
  bool _isLoading = false;

  Future<void> onAuthentifier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedLogin = prefs.getString("login");
      String? savedPassword = prefs.getString("password");

      if (savedLogin != null &&
          savedPassword != null &&
          txtLogin.text.trim() == savedLogin &&
          txtPassword.text == savedPassword) {
        await prefs.setBool("connecte", true);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Identifiant ou mot de passe incorrect.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    txtLogin.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Authentification'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: txtLogin,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Identifiant'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Veuillez saisir votre identifiant.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: txtPassword,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => onAuthentifier(),
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez saisir votre mot de passe.'
                        : null,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : onAuthentifier,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Connexion', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushNamed(context, '/inscription'),
                    child: const Text(
                      'Nouvel utilisateur',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}