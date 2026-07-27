import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_model.dart';

/// Document `users/{userId}/publicProfile/main`.
///
/// Expose uniquement les informations qu'un passager doit pouvoir lire
/// sur un chauffeur (nom, note, véhicule) sans ouvrir tout le document
/// `users/{userId}` qui contient des données privées (téléphone, contact
/// d'urgence, documents d'identité...).
///
/// Ce document n'est jamais écrit directement par le client : il est
/// maintenu à jour par la Cloud Function `onUserWrite` (voir
/// functions/src/index.ts) à chaque modification du profil chauffeur.
class PublicProfileModel {
  final String displayName;
  final double ratingAverage;
  final int ratingCount;
  final ChauffeurVehicule vehicule;
  final bool disponible;

  const PublicProfileModel({
    required this.displayName,
    required this.ratingAverage,
    required this.ratingCount,
    required this.vehicule,
    required this.disponible,
  });

  factory PublicProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return PublicProfileModel(
      displayName: data['displayName'] as String? ?? '',
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      vehicule: ChauffeurVehicule.fromMap(
        data['vehicule'] as Map<String, dynamic>?,
      ),
      disponible: data['disponible'] as bool? ?? false,
    );
  }
}
