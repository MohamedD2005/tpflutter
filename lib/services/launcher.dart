import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  static Future<void> makePhoneCall(
    String phoneNumber,
    BuildContext context,
  ) async {
    await _launch(Uri(scheme: 'tel', path: phoneNumber), context);
  }

  static Future<void> sendSMS(
    String phoneNumber,
    BuildContext context,
  ) async {
    await _launch(Uri(scheme: 'sms', path: phoneNumber), context);
  }

  static Future<void> sendEmail(String email, BuildContext context) async {
    await _launch(Uri(scheme: 'mailto', path: email), context);
  }

  static Future<void> _launch(Uri uri, BuildContext context) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          context.mounted) {
        _showError(context, 'Aucune application compatible trouvée.');
      }
    } catch (error) {
      if (context.mounted) _showError(context, 'Impossible d’ouvrir le lien: $error');
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}