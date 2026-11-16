import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/contact.model.dart';
import '../services/mongodb.helper.dart';

class ContactFormPage extends StatefulWidget {
  final Contact? contact;

  const ContactFormPage({super.key, this.contact});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _imageBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _nomController.text = contact?.nom ?? '';
    _prenomController.text = contact?.prenom ?? '';
    _telephoneController.text = contact?.telephone ?? '';
    _emailController.text = contact?.email ?? '';
    _imageBase64 = contact?.imageBase64;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (mounted) setState(() => _imageBase64 = base64Encode(bytes));
    } catch (error) {
      if (mounted) _showMessage('Impossible de charger la photo: $error');
    }
  }

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Caméra'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final contact = Contact(
        id: widget.contact?.id,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        imageBase64: _imageBase64,
      );

      if (widget.contact == null) {
        await MongoDBHelper.instance.insertContact(contact);
      } else if (!await MongoDBHelper.instance.updateContact(contact)) {
        throw StateError('Le contact n’a pas pu être modifié.');
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showMessage('Erreur lors de la sauvegarde: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier contact' : 'Nouveau contact'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  InkWell(
                    onTap: _isSaving ? null : _chooseImage,
                    borderRadius: BorderRadius.circular(48),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _imageBase64 == null
                          ? null
                          : MemoryImage(base64Decode(_imageBase64!)),
                      child: _imageBase64 == null
                          ? const Icon(Icons.add_a_photo_outlined, size: 32)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Ajouter une photo'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nomController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Veuillez saisir le nom.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prenomController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Veuillez saisir le prénom.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Veuillez saisir le téléphone.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (optionnel)',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isNotEmpty && !email.contains('@')) {
                        return 'Veuillez saisir un email valide.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveContact,
                      icon: _isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isEditing ? Icons.save_outlined : Icons.add),
                      label: Text(isEditing ? 'Modifier' : 'Ajouter'),
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