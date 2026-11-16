import 'package:mongo_dart/mongo_dart.dart';

class Contact {
  final ObjectId? id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? email;
  final String? imageBase64;

  const Contact({
    this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.email,
    this.imageBase64,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) '_id': id,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'email': email,
        'imageBase64': imageBase64,
      };

  factory Contact.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    return Contact(
        id: rawId == null
            ? null
            : rawId is ObjectId
                ? rawId
                : ObjectId.parse(rawId as String),
        nom: map['nom'] as String? ?? '',
        prenom: map['prenom'] as String? ?? '',
        telephone: map['telephone'] as String? ?? '',
        email: map['email'] as String?,
        imageBase64: map['imageBase64'] as String?,
      );
  }
}