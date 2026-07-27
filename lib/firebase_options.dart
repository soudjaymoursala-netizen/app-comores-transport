// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

// Options de configuration Firebase du projet `app-comores-transport`.
//
// Valeurs reprises de android/app/google-services.json et
// ios/Runner/GoogleService-Info.plist (fournies par la console Firebase).
// Seuls Android et iOS sont ciblés par ce projet (pas de web/desktop).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions ne sont pas configurées pour le web : ce '
        'projet ne cible que Android et iOS.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ne sont pas configurées pour cette '
          'plateforme.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIVVdphH_OW0yxyNJvEV2cGPFSdSuQfSg',
    appId: '1:34977625962:android:1d538d3d35c5dc87c35713',
    messagingSenderId: '34977625962',
    projectId: 'app-comores-transport',
    storageBucket: 'app-comores-transport.firebasestorage.app',
    databaseURL:
        'https://app-comores-transport-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvpIWj_niEK67oJd92xgx_bU1vFl81UH8',
    appId: '1:34977625962:ios:cceed7e297a072d4c35713',
    messagingSenderId: '34977625962',
    projectId: 'app-comores-transport',
    storageBucket: 'app-comores-transport.firebasestorage.app',
    databaseURL:
        'https://app-comores-transport-default-rtdb.europe-west1.firebasedatabase.app',
    iosBundleId: 'com.appcomorestransport.app',
  );
}
