import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/session_provider.dart';

/// Affiché une seule fois, juste après la toute première connexion par
/// SMS, quand aucun document `users/{uid}` n'existe encore. Crée le
/// document utilisateur avec le rôle "passager" par défaut.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  String _langue = 'fr';
  bool _enregistrementEnCours = false;

  static const _libellesLangues = {
    'fr': 'Français',
    'sw': 'Shikomori',
    'ar': 'العربية',
    'en': 'English',
  };

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enregistrementEnCours = true);
    await context.read<SessionProvider>().completerInscription(
          displayName: _nomController.text.trim(),
          preferredLanguage: _langue,
        );
    // Pas besoin de gérer la navigation : le SessionProvider bascule
    // automatiquement en StatutSession.connecte dès que le document
    // Firestore est créé, ce que l'AuthGate détecte pour changer d'écran.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenue')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Quelques informations pour finaliser votre inscription.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
                validator: (valeur) => (valeur == null || valeur.trim().isEmpty)
                    ? 'Le nom est requis'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _langue,
                decoration: const InputDecoration(
                  labelText: 'Langue préférée',
                  border: OutlineInputBorder(),
                ),
                items: UserModel.languesSupportees
                    .map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(_libellesLangues[code] ?? code),
                        ))
                    .toList(),
                onChanged: (valeur) {
                  if (valeur != null) setState(() => _langue = valeur);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _enregistrementEnCours ? null : _valider,
                child: _enregistrementEnCours
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
