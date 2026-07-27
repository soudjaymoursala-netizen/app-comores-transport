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
stockage local avec des garanties transactionnelles fortes. Recommandation
: **Drift** (ORM SQL sur SQLite, transactions ACID, mature et activement
maintenu). Alternatives évaluées : Isar (rapide mais maintenance
communautaire incertaine depuis 2024) et Hive (trop simple pour les
requêtes par statut/date dont le dispatch aura besoin). Cette librairie
sera ajoutée au `pubspec.yaml` au démarrage du module Dispatch, pas
avant, pour ne pas alourdir ce module Auth avec une dépendance inutilisée.

## Configuration Firebase (à faire avant de lancer l'app)

Le fichier `lib/firebase_options.dart` fourni est un **placeholder** :
il fait volontairement échouer `Firebase.initializeApp()` tant qu'il n'a
pas été régénéré avec un vrai projet Firebase (impossible à créer depuis
cet environnement, qui n'a pas d'accès interactif à un compte Google
Cloud).

1. Créer un projet Firebase sur https://console.firebase.google.com
2. Activer **Authentication → Phone** et **Cloud Firestore**.
3. Installer la CLI FlutterFire puis lancer, à la racine du projet :
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<id-du-projet-firebase>
   ```
   Cela régénère `lib/firebase_options.dart` et télécharge
   `android/app/google-services.json` /
   `ios/Runner/GoogleService-Info.plist` (fichiers volontairement exclus
   du dépôt via `.gitignore`, car spécifiques au projet Firebase réel).
4. Mettre à jour `.firebaserc` avec l'ID du projet.
5. Déployer les règles Firestore :
   ```bash
   firebase deploy --only firestore:rules
   ```
6. Installer et déployer les Cloud Functions :
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
