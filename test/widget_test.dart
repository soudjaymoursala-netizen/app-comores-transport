// Test unitaire du modèle UserModel.
//
// Note : un test de widget complet sur ComoresTransportApp nécessiterait
// d'initialiser Firebase (impossible en environnement de test sans
// mocks dédiés à firebase_core/firebase_auth). On se limite ici à la
// logique métier pure du modèle, qui ne dépend d'aucun SDK Firebase.

import 'package:flutter_test/flutter_test.dart';

import 'package:app_comores_transport/models/user_model.dart';

void main() {
  group('UserModel.hasBothRoles', () {
    test('faux pour un utilisateur uniquement passager', () {
      const utilisateur = UserModel(
        uid: 'u1',
        phone: '+2693312345',
        displayName: 'Test',
        roles: [UserModel.rolePassager],
      );
      expect(utilisateur.hasBothRoles, isFalse);
    });

    test('vrai quand les deux rôles sont présents', () {
      const utilisateur = UserModel(
        uid: 'u1',
        phone: '+2693312345',
        displayName: 'Test',
        roles: [UserModel.rolePassager, UserModel.roleChauffeur],
      );
      expect(utilisateur.hasBothRoles, isTrue);
    });
  });
}
