import 'dart:convert';

import 'package:flutter/material.dart';

import '../menu/drawer.widget.dart';
import '../models/contact.model.dart';
import '../services/mongodb.helper.dart';
import 'contact-details.page.dart';
import 'contact-form.page.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final _searchController = TextEditingController();
  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;

  List<Contact> get _filteredContacts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _contacts;
    return _contacts.where((contact) {
      final name = '${contact.prenom} ${contact.nom}'.toLowerCase();
      return name.contains(query) || contact.telephone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final contacts = await MongoDBHelper.instance.getAllContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm({Contact? contact}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ContactFormPage(contact: contact),
      ),
    );
    if (saved == true && mounted) await _loadContacts();
  }

  Future<void> _openDetails(Contact contact) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ContactDetailsPage(contact: contact),
      ),
    );
    if (changed == true && mounted) await _loadContacts();
  }

  Widget _buildAvatar(Contact contact) {
    final image = contact.imageBase64;
    final initials = '${_firstCharacter(contact.prenom)}${_firstCharacter(contact.nom)}';
    return CircleAvatar(
      backgroundColor: Colors.blue.shade100,
      backgroundImage: image == null ? null : MemoryImage(base64Decode(image)),
      child: image == null
          ? Text(initials, style: const TextStyle(fontWeight: FontWeight.bold))
          : null,
    );
  }

  String _firstCharacter(String value) => value.isEmpty ? '' : value.substring(0, 1);

  @override
  Widget build(BuildContext context) {
    final visibleContacts = _filteredContacts;
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom ou téléphone',
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text('Contacts (${_contacts.length})'),
        actions: [
          IconButton(
            tooltip: _isSearching ? 'Fermer la recherche' : 'Rechercher',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _isLoading ? null : _loadContacts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _MessageView(
                  icon: Icons.cloud_off_outlined,
                  title: 'Impossible de charger les contacts',
                  details: _errorMessage,
                  onRetry: _loadContacts,
                )
              : visibleContacts.isEmpty
                  ? _MessageView(
                      icon: Icons.contacts_outlined,
                      title: _contacts.isEmpty ? 'Aucun contact' : 'Aucun résultat',
                      details: _contacts.isEmpty
                          ? 'Appuyez sur + pour ajouter un contact.'
                          : 'Essayez un autre nom ou numéro.',
                    )
                  : ListView.separated(
                      itemCount: visibleContacts.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final contact = visibleContacts[index];
                        return ListTile(
                          leading: _buildAvatar(contact),
                          title: Text('${contact.prenom} ${contact.nom}'),
                          subtitle: Text(contact.telephone),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetails(contact),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter un contact',
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? details;
  final VoidCallback? onRetry;

  const _MessageView({
    required this.icon,
    required this.title,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(details!, textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}