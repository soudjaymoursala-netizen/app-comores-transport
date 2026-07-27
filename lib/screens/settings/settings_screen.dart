import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/session_provider.dart';
import '../../widgets/role_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final utilisateur = session.utilisateur;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (utilisateur != null) ...[
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(utilisateur.displayName),
              subtitle: Text(utilisateur.phone),
            ),
            const Divider(),
            const RoleToggle(),
            if (!utilisateur.roles.contains(UserModel.roleChauffeur))
              ListTile(
                leading: const Icon(Icons.local_taxi_outlined),
                title: const Text('Devenir chauffeur'),
                subtitle: const Text(
                  'Ajoute le rôle chauffeur à votre compte (vérification '
                  'des documents requise avant activation).',
                ),
                onTap: () => session.userService.devenirChauffeur(
                  utilisateur.uid,
                ),
              ),
            if (utilisateur.chauffeurProfile != null)
              ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: const Text('Statut de vérification chauffeur'),
                subtitle: Text(
                  _libelleStatut(
                    utilisateur.chauffeurProfile!.verificationStatus,
                  ),
                ),
              ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: session.deconnexion,
          ),
        ],
      ),
    );
  }

  String _libelleStatut(String statut) {
    switch (statut) {
      case ChauffeurProfile.statusEnAttente:
        return 'En attente de vérification';
      case ChauffeurProfile.statusVerifie:
        return 'Vérifié';
      case ChauffeurProfile.statusRejete:
        return 'Rejeté — documents à resoumettre';
      default:
        return 'Non soumis';
    }
  }
}
