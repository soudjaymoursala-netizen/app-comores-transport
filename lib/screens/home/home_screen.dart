import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/session_provider.dart';
import '../settings/settings_screen.dart';

/// Écran d'accueil minimal, provisoire : sert de point d'entrée après
/// connexion en attendant le module Dispatch (taxi temps réel). Affiche
/// le rôle actif pour vérifier visuellement que la bascule fonctionne.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<SessionProvider>().utilisateur;
    final estChauffeur = utilisateur?.activeRole == UserModel.roleChauffeur;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comores Transport — ${estChauffeur ? "Chauffeur" : "Passager"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bonjour ${utilisateur?.displayName ?? ""}\n'
          'Module Dispatch à venir.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
