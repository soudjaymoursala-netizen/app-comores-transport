import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/session_provider.dart';

/// Bascule passager/chauffeur. N'est rendu visible que si l'utilisateur
/// possède les deux rôles (`UserModel.hasBothRoles`) : un utilisateur qui
/// n'a que "passager" ne doit jamais voir ce contrôle.
class RoleToggle extends StatelessWidget {
  const RoleToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<SessionProvider>().utilisateur;

    if (utilisateur == null || !utilisateur.hasBothRoles) {
      return const SizedBox.shrink();
    }

    final estChauffeur = utilisateur.activeRole == UserModel.roleChauffeur;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(estChauffeur ? Icons.local_taxi : Icons.person),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                estChauffeur ? 'Mode chauffeur actif' : 'Mode passager actif',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Switch(
              value: estChauffeur,
              onChanged: (activerChauffeur) {
                final nouveauRole = activerChauffeur
                    ? UserModel.roleChauffeur
                    : UserModel.rolePassager;
                context
                    .read<SessionProvider>()
                    .userService
                    .basculerRoleActif(utilisateur.uid, nouveauRole);
              },
            ),
          ],
        ),
      ),
    );
  }
}
