import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Accès Firestore au document `users/{userId}`.
///
/// Note offline : `cloud_firestore` conserve automatiquement en cache
/// local (SQLite) le dernier document lu et met en file d'attente les
/// écritures effectuées hors connexion, qui sont rejouées à la reconnexion.
/// Cela suffit pour le profil utilisateur (peu volatile). Les données plus
/// critiques comme une réservation en cours seront gérées par une couche
/// de persistance locale dédiée dans le module Dispatch.
class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Stream<UserModel?> streamUtilisateur(String uid) {
    return _usersRef.doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromFirestore(doc) : null,
        );
  }

  Future<UserModel?> getUtilisateur(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  /// Crée le document utilisateur lors de la toute première connexion.
  Future<void> creerUtilisateur(UserModel utilisateur) {
    return _usersRef
        .doc(utilisateur.uid)
        .set(utilisateur.toFirestore(avecCreatedAt: true));
  }

  Future<void> mettreAJourProfil(
    String uid, {
    String? displayName,
    String? preferredLanguage,
    String? emergencyContact,
  }) {
    final donnees = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
    };
    if (donnees.isEmpty) return Future.value();
    return _usersRef.doc(uid).update(donnees);
  }

  /// Bascule le rôle actif. N'est appelé que si l'utilisateur possède déjà
  /// les deux rôles (vérifié côté UI via [UserModel.hasBothRoles] et
  /// implicitement par les règles Firestore qui n'autorisent que la
  /// modification de ses propres données).
  Future<void> basculerRoleActif(String uid, String nouveauRole) {
    return _usersRef.doc(uid).update({'activeRole': nouveauRole});
  }

  /// Ajoute le rôle "chauffeur" à un compte passager existant, avec un
  /// profil chauffeur vierge (`verificationStatus: non_soumis`). Ne rend
  /// PAS le chauffeur vérifié : la vérification manuelle des documents
  /// reste effectuée côté admin via Cloud Function.
  Future<void> devenirChauffeur(String uid) {
    return _usersRef.doc(uid).update({
      'roles': FieldValue.arrayUnion([UserModel.roleChauffeur]),
      'chauffeurProfile': const ChauffeurProfile().toMap(),
    });
  }
}
