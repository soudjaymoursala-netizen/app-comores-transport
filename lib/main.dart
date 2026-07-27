import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth/phone_number_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/session_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ComoresTransportApp());
}

class ComoresTransportApp extends StatelessWidget {
  const ComoresTransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: MaterialApp(
        title: 'Comores Transport',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// Route vers l'écran adapté selon l'état de session : connexion par
/// téléphone, complétion de profil (première connexion), ou accueil.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final statut = context.watch<SessionProvider>().statut;

    switch (statut) {
      case StatutSession.chargement:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case StatutSession.deconnecte:
        return const PhoneNumberScreen();
      case StatutSession.nouveauCompte:
        return const ProfileSetupScreen();
      case StatutSession.connecte:
        return const HomeScreen();
    }
  }
}
