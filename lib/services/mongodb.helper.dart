import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:http/http.dart' as http;
import '../models/contact.model.dart';

class MongoDBHelper {
  MongoDBHelper._();

  static final MongoDBHelper instance = MongoDBHelper._();
  static const String _mongoUri = String.fromEnvironment('MONGO_URI');
  static const String _apiBaseUrl = String.fromEnvironment(
    'CONTACTS_API_URL',
    defaultValue: 'http://127.0.0.1:3000/api',
  );
  static const String _collectionName = 'contacts';

  Db? _db;
  DbCollection? _contacts;

  Future<DbCollection> get _collection async {
    if (_mongoUri.isEmpty) {
      throw StateError(
        'MongoDB is not configured. Start Flutter with --dart-define=MONGO_URI=your_uri.',
      );
    }

    if (_db == null || !_db!.isConnected) {
      _db = await Db.create(_mongoUri);
      await _db!.open();
      _contacts = _db!.collection(_collectionName);
    }

    return _contacts!;
  }

  Future<ObjectId> insertContact(Contact contact) async {
    if (kIsWeb) {
      final result = await _requestApi('POST', '/contacts', body: _apiMap(contact));
      return ObjectId.parse(result['_id'] as String);
    }
    final result = await (await _collection).insertOne(contact.toMap());
    return result.id as ObjectId;
  }

  Future<List<Contact>> getAllContacts() async {
    if (kIsWeb) {
      final result = await _requestApi('GET', '/contacts') as List<dynamic>;
      return result
          .map((item) => Contact.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    final documents = await (await _collection).find().toList();
    return documents.map(Contact.fromMap).toList();
  }

  Future<Contact?> getContactById(ObjectId id) async {
    if (kIsWeb) {
      final result = await _requestApi('GET', '/contacts/${id.oid}');
      return Contact.fromMap(result);
    }
    final document = await (await _collection).findOne(where.eq('_id', id));
    return document == null ? null : Contact.fromMap(document);
  }

  Future<bool> updateContact(Contact contact) async {
    final id = contact.id;
    if (id == null) return false;

    if (kIsWeb) {
      await _requestApi(
        'PUT',
        '/contacts/${id.oid}',
        body: _apiMap(contact),
      );
      return true;
    }

    final result = await (await _collection).updateOne(
      where.eq('_id', id),
      modify
          .set('nom', contact.nom)
          .set('prenom', contact.prenom)
          .set('telephone', contact.telephone)
          .set('email', contact.email)
          .set('imageBase64', contact.imageBase64),
    );
    return result.isSuccess;
  }

  Future<bool> deleteContact(ObjectId id) async {
    if (kIsWeb) {
      await _requestApi('DELETE', '/contacts/${id.oid}');
      return true;
    }
    final result = await (await _collection).deleteOne(where.eq('_id', id));
    return result.isSuccess;
  }

  Future<List<Contact>> searchContacts(String query) async {
    if (kIsWeb) {
      final contacts = await getAllContacts();
      final normalizedQuery = query.trim().toLowerCase();
      return contacts.where((contact) {
        final name = '${contact.prenom} ${contact.nom}'.toLowerCase();
        return name.contains(normalizedQuery) ||
            contact.telephone.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    final pattern = RegExp.escape(query.trim());
    if (pattern.isEmpty) return getAllContacts();

    final selector = where
        .match('nom', pattern, caseInsensitive: true)
        .or(where.match('prenom', pattern, caseInsensitive: true))
        .or(where.match('telephone', pattern, caseInsensitive: true));
    final documents = await (await _collection).find(selector).toList();
    return documents.map(Contact.fromMap).toList();
  }

  Future<void> close() async {
    final db = _db;
    if (db != null && db.isConnected) await db.close();
    _db = null;
    _contacts = null;
  }

  Map<String, dynamic> _apiMap(Contact contact) => {
        'nom': contact.nom,
        'prenom': contact.prenom,
        'telephone': contact.telephone,
        'email': contact.email,
        'imageBase64': contact.imageBase64,
      };

  Future<dynamic> _requestApi(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request(method, Uri.parse('$_apiBaseUrl$path'));
      if (body != null) {
        request.headers['content-type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? decoded['error']
            : 'Contacts API error (${response.statusCode})';
        throw StateError('$message');
      }
      return decoded;
    } finally {
      client.close();
    }
  }
}