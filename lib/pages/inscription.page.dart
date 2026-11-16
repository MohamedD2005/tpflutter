import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final txtLogin = TextEditingController();
  final txtPassword = TextEditingController();
  bool _isLoading = false;

  Future<void> onInscrire() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('login', txtLogin.text.trim());
      await prefs.setString('password', txtPassword.text);
      await prefs.setBool('connecte', true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
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
        title: const Text('Page Inscription'),
        backgroundColor: Colors.blue,
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
                        ? 'Veuillez saisir un identifiant.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: txtPassword,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => onInscrire(),
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                    validator: (value) => value == null || value.length < 6
                        ? 'Le mot de passe doit contenir au moins 6 caractères.'
                        : null,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : onInscrire,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Inscription', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushNamed(context, '/authentification'),
                    child: const Text(
                      "J'ai déjà un compte",
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