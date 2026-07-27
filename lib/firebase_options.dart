// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

// GÉNÉRÉ MANUELLEMENT — À REMPLACER.
//
// Ce fichier est normalement généré automatiquement par la CLI FlutterFire :
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<id-du-projet-firebase>
//
// Cette commande nécessite une authentification interactive Google Cloud
// et un vrai projet Firebase, ce qui n'est pas disponible dans cet
// environnement d'exécution. Les valeurs ci-dessous sont des placeholders
// qui font échouer `Firebase.initializeApp()` intentionnellement (plutôt
// que d'utiliser silencieusement un faux projet) tant que la commande
// `flutterfire configure` n'a pas été lancée avec de vrais identifiants.
//
// Voir README.md, section "Configuration Firebase" pour la procédure.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ne sont pas configurées pour cette '
          'plateforme. Lancez `flutterfire configure` pour la générer.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    appId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    projectId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    appId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    projectId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    appId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    projectId: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REMPLACER_APRES_FLUTTERFIRE_CONFIGURE',
    iosBundleId: 'km.comorestransport.appComoresTransport',
  );
}
