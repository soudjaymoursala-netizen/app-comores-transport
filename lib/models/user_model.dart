import 'package:cloud_firestore/cloud_firestore.dart';

/// Documents d'identité fournis par un chauffeur en cours de vérification.
class ChauffeurDocuments {
  final String? permisUrl;
  final String? carteGriseUrl;
  final String? photoIdUrl;

  const ChauffeurDocuments({
    this.permisUrl,
    this.carteGriseUrl,
    this.photoIdUrl,
  });

  factory ChauffeurDocuments.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChauffeurDocuments();
    return ChauffeurDocuments(
      permisUrl: map['permisUrl'] as String?,
      carteGriseUrl: map['carteGriseUrl'] as String?,
      photoIdUrl: map['photoIdUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'permisUrl': permisUrl,
        'carteGriseUrl': carteGriseUrl,
        'photoIdUrl': photoIdUrl,
      };
}

/// Informations sur le véhicule déclaré par le chauffeur.
class ChauffeurVehicule {
  final String? type;
  final String? immatriculation;
  final String? modele;

  const ChauffeurVehicule({
    this.type,
    this.immatriculation,
    this.modele,
  });

  factory ChauffeurVehicule.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChauffeurVehicule();
    return ChauffeurVehicule(
      type: map['type'] as String?,
      immatriculation: map['immatriculation'] as String?,
      modele: map['modele'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'immatriculation': immatriculation,
        'modele': modele,
      };
}

/// Profil chauffeur : n'existe dans Firestore que si "chauffeur" figure
/// dans `roles`. `verificationStatus` est en lecture seule côté client :
/// il n'est modifié que par une Cloud Function après validation manuelle
/// d'un administrateur (voir functions/src/index.ts).
class ChauffeurProfile {
  static const String statusNonSoumis = 'non_soumis';
  static const String statusEnAttente = 'en_attente';
  static const String statusVerifie = 'verifie';
  static const String statusRejete = 'rejete';

  final String verificationStatus;
  final ChauffeurDocuments documents;
  final ChauffeurVehicule vehicule;
  final bool disponible;

  const ChauffeurProfile({
    this.verificationStatus = statusNonSoumis,
    this.documents = const ChauffeurDocuments(),
    this.vehicule = const ChauffeurVehicule(),
    this.disponible = false,
  });

  factory ChauffeurProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChauffeurProfile();
    return ChauffeurProfile(
      verificationStatus:
          map['verificationStatus'] as String? ?? statusNonSoumis,
      documents: ChauffeurDocuments.fromMap(
        map['documents'] as Map<String, dynamic>?,
      ),
      vehicule: ChauffeurVehicule.fromMap(
        map['vehicule'] as Map<String, dynamic>?,
      ),
      disponible: map['disponible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'verificationStatus': verificationStatus,
        'documents': documents.toMap(),
        'vehicule': vehicule.toMap(),
        'disponible': disponible,
      };

  ChauffeurProfile copyWith({
    String? verificationStatus,
    ChauffeurDocuments? documents,
    ChauffeurVehicule? vehicule,
    bool? disponible,
  }) {
    return ChauffeurProfile(
      verificationStatus: verificationStatus ?? this.verificationStatus,
      documents: documents ?? this.documents,
      vehicule: vehicule ?? this.vehicule,
      disponible: disponible ?? this.disponible,
    );
  }
}

/// Modèle correspondant au document Firestore `users/{userId}`.
///
/// Les rôles ("passager" / "chauffeur") sont conservés en `String` brute
/// plutôt qu'en enum Dart afin de matcher exactement les valeurs stockées
/// côté Firestore et de rester compatible si une nouvelle valeur est
/// ajoutée côté back-office avant la mise à jour de l'app mobile.
class UserModel {
  static const String rolePassager = 'passager';
  static const String roleChauffeur = 'chauffeur';

  static const List<String> languesSupportees = ['fr', 'sw', 'ar', 'en'];

  final String uid;
  final String phone;
  final String displayName;
  final String preferredLanguage;
  final String activeRole;
  final List<String> roles;
  final DateTime? createdAt;
  final double ratingAverage;
  final int ratingCount;
  final ChauffeurProfile? chauffeurProfile;
  final String? emergencyContact;

  const UserModel({
    required this.uid,
    required this.phone,
    required this.displayName,
    this.preferredLanguage = 'fr',
    this.activeRole = rolePassager,
    this.roles = const [rolePassager],
    this.createdAt,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.chauffeurProfile,
    this.emergencyContact,
  });

  /// Vrai si l'utilisateur peut basculer entre les deux rôles.
  bool get hasBothRoles =>
      roles.contains(rolePassager) && roles.contains(roleChauffeur);

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel(
      uid: doc.id,
      phone: data['phone'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      preferredLanguage: data['preferredLanguage'] as String? ?? 'fr',
      activeRole: data['activeRole'] as String? ?? rolePassager,
      roles: List<String>.from(data['roles'] as List? ?? [rolePassager]),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      chauffeurProfile: data.containsKey('chauffeurProfile')
          ? ChauffeurProfile.fromMap(
              data['chauffeurProfile'] as Map<String, dynamic>?,
            )
          : null,
      emergencyContact: data['emergencyContact'] as String?,
    );
  }

  /// Sérialisation pour écriture Firestore. `createdAt` n'est inclus que
  /// lors de la création initiale (voir [UserService.creerUtilisateur]) :
  /// on ne veut jamais l'écraser lors d'une mise à jour ultérieure.
  Map<String, dynamic> toFirestore({bool avecCreatedAt = false}) {
    final map = <String, dynamic>{
      'uid': uid,
      'phone': phone,
      'displayName': displayName,
      'preferredLanguage': preferredLanguage,
      'activeRole': activeRole,
      'roles': roles,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      if (chauffeurProfile != null) 'chauffeurProfile': chauffeurProfile!.toMap(),
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
    };
    if (avecCreatedAt) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }
    return map;
  }

  UserModel copyWith({
    String? displayName,
    String? preferredLanguage,
    String? activeRole,
    List<String>? roles,
    double? ratingAverage,
    int? ratingCount,
    ChauffeurProfile? chauffeurProfile,
    String? emergencyContact,
  }) {
    return UserModel(
      uid: uid,
      phone: phone,
      displayName: displayName ?? this.displayName,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      activeRole: activeRole ?? this.activeRole,
      roles: roles ?? this.roles,
      createdAt: createdAt,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      chauffeurProfile: chauffeurProfile ?? this.chauffeurProfile,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }
}
