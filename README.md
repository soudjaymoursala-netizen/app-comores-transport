# Comores Transport

Application mobile (iOS/Android, Flutter) de réservation de transport aux
Comores (Grande Comore, Anjouan, Mohéli) : taxi (dispatch temps réel),
événementiel (bus/groupe), utilitaire/camion, location self-drive. Un
même compte peut basculer entre le rôle passager et le rôle chauffeur.

## Stack

- **Flutter / Dart** — cible des devices Android bas/moyen de gamme.
- **Firebase** — Auth (numéro de téléphone), Firestore, Cloud Functions,
  FCM à venir.
- **Google Maps** — carte/géolocalisation (module Dispatch, à venir).
- **Stockage offline** — voir la note ci-dessous : WatermelonDB n'existe
  pas pour Flutter, remplacé par **Drift** à partir du module Dispatch.

## Structure du projet

```
lib/
├── models/     # UserModel, ChauffeurProfile, PublicProfileModel, ...
├── screens/    # auth/, settings/, home/ (un sous-dossier par flux)
├── services/   # AuthService, UserService, SessionProvider (état global)
└── widgets/    # composants réutilisables (ex. RoleToggle)

firestore.rules            # règles de sécurité Firestore
firestore.indexes.json
firebase.json
functions/                 # Cloud Functions (TypeScript)
```

## Note sur le stockage offline (WatermelonDB → Drift)

Le brief de départ mentionne WatermelonDB, mais cette librairie est
spécifique à React Native/JavaScript et n'a pas de portage Flutter
officiel. Pour ce module (Auth & bascule de rôle), aucun stockage local
dédié n'était nécessaire : le cache offline intégré de `cloud_firestore`
(persistance SQLite automatique + file d'attente des écritures hors
ligne) suffit pour le profil utilisateur, qui change rarement.

Pour le module suivant (Dispatch temps réel), où la contrainte est
explicitement de **ne jamais perdre une réservation en cours** lors
d'une coupure réseau/électrique, ce cache ne suffit plus : il faut un
stockage local avec des garanties transactionnelles fortes.

**Décision validée : Drift** (ORM SQL sur SQLite, transactions ACID,
mature et activement maintenu). Alternatives évaluées et écartées : Isar
(rapide mais maintenance communautaire incertaine depuis 2024) et Hive
(trop simple pour les requêtes par statut/date dont le dispatch aura
besoin). Cette librairie sera ajoutée au `pubspec.yaml` au démarrage du
module Dispatch, pas avant, pour ne pas alourdir ce module Auth avec une
dépendance inutilisée.

## Configuration Firebase

Le projet est connecté au projet Firebase réel **app-comores-transport**
(n° 34977625962, Firestore en `europe-west9`, Realtime Database en
`europe-west1`). `lib/firebase_options.dart`,
`android/app/google-services.json` et `ios/Runner/GoogleService-Info.plist`
contiennent les vraies valeurs de config (Android : package
`com.appcomorestransport.app` ; iOS : bundle `com.appcomorestransport.app`).

Ces fichiers sont volontairement commités : ce sont des identifiants
client (pas des secrets serveur), la vraie protection venant des règles
Firestore et des restrictions d'API key. **Recommandation** : dans Google
Cloud Console → APIs & Services → Identifiants, restreindre chaque clé API
Firebase à son package Android / bundle iOS respectif, si ce n'est pas
déjà fait.

Reste à faire manuellement (CLI Firebase non utilisable depuis cet
environnement, faute d'authentification navigateur) :

1. Déployer les règles Firestore — soit en collant le contenu de
   `firestore.rules` dans Firebase Console → Firestore → Règles → Publier,
   soit depuis une machine authentifiée :
   ```bash
   firebase deploy --only firestore:rules
   ```
2. Installer et déployer les Cloud Functions :
   ```bash
   cd functions && npm install && cd ..
   firebase deploy --only functions
   ```

## Modèle de données Firestore

Voir `lib/models/user_model.dart` pour le détail. Résumé :

```
users/{userId}
├── uid, phone, displayName, preferredLanguage, activeRole
├── roles: ["passager"] ou ["passager", "chauffeur"]
├── ratingAverage, ratingCount, createdAt, emergencyContact
├── chauffeurProfile: { verificationStatus, documents, vehicule, disponible }
│     (présent uniquement si "chauffeur" ∈ roles)
└── publicProfile/main   (sous-collection, écrite uniquement par Cloud Function)
      { displayName, ratingAverage, ratingCount, vehicule, disponible }
```

`chauffeurProfile.verificationStatus` n'est **jamais modifiable
directement par le client** une fois défini (voir `firestore.rules`) :
seule la Cloud Function `validerChauffeur` (réservée aux administrateurs
via custom claim) peut le faire, après vérification manuelle des
documents.

## Lancer le projet

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
