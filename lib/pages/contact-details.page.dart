import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/contact.model.dart';
import '../services/launcher.dart';
import '../services/mongodb.helper.dart';
import 'contact-form.page.dart';

class ContactDetailsPage extends StatefulWidget {
  final Contact contact;

  const ContactDetailsPage({super.key, required this.contact});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  late Contact _contact = widget.contact;
  bool _isBusy = false;

  Future<void> _editContact() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ContactFormPage(contact: _contact),
      ),
    );
    if (updated != true || !mounted) return;

    final id = _contact.id;
    if (id == null) return;
    final contact = await MongoDBHelper.instance.getContactById(id);
    if (mounted && contact != null) setState(() => _contact = contact);
  }

  Future<void> _deleteContact() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce contact ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || _contact.id == null) return;

    setState(() => _isBusy = true);
    try {
      final deleted = await MongoDBHelper.instance.deleteContact(_contact.id!);
      if (!mounted) return;
      if (deleted) {
        Navigator.pop(context, true);
      } else {
        _showMessage('Le contact n’a pas pu être supprimé.');
      }
    } catch (error) {
      if (mounted) _showMessage('Erreur lors de la suppression: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) _showMessage('$label copié.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _firstCharacter(String value) => value.isEmpty ? '' : value.substring(0, 1);

  @override
  Widget build(BuildContext context) {
    final contact = _contact;
    final image = contact.imageBase64;
    final initials =
        '${_firstCharacter(contact.prenom)}${_firstCharacter(contact.nom)}';

    return Scaffold(
      appBar: AppBar(
        title: Text('${contact.prenom} ${contact.nom}'),
        actions: [
          IconButton(
            tooltip: 'Modifier',
            onPressed: _isBusy ? null : _editContact,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Supprimer',
            onPressed: _isBusy ? null : _deleteContact,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: _isBusy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Container(
                  height: 190,
                  color: Colors.blue.shade50,
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage:
                        image == null ? null : MemoryImage(base64Decode(image)),
                    child: image == null
                        ? Text(initials, style: const TextStyle(fontSize: 28))
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${contact.prenom} ${contact.nom}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 24,
                    children: [
                      _QuickAction(
                        icon: Icons.call,
                        label: 'Appeler',
                        color: Colors.green,
                        onPressed: () => LauncherService.makePhoneCall(
                          contact.telephone,
                          context,
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.message,
                        label: 'Message',
                        color: Colors.blue,
                        onPressed: () => LauncherService.sendSMS(
                          contact.telephone,
                          context,
                        ),
                      ),
                      if (contact.email?.isNotEmpty == true)
                        _QuickAction(
                          icon: Icons.email,
                          label: 'Email',
                          color: Colors.deepOrange,
                          onPressed: () => LauncherService.sendEmail(
                            contact.email!,
                            context,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Téléphone'),
                  subtitle: Text(contact.telephone),
                  trailing: IconButton(
                    tooltip: 'Copier le téléphone',
                    onPressed: () => _copy(contact.telephone, 'Téléphone'),
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ),
                if (contact.email?.isNotEmpty == true)
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(contact.email!),
                    trailing: IconButton(
                      tooltip: 'Copier l’email',
                      onPressed: () => _copy(contact.email!, 'Email'),
                      icon: const Icon(Icons.copy_outlined),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          tooltip: label,
          onPressed: onPressed,
          style: IconButton.styleFrom(backgroundColor: color),
          icon: Icon(icon),
        ),
        Text(label),
      ],
    );
  }
}