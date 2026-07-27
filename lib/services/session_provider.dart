import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'auth_service.dart';
import 'user_service.dart';

enum StatutSession { chargement, deconnecte, nouveauCompte, connecte }

/// État global de session exposé via `provider`. Combine l'état
/// d'authentification Firebase Auth et le document Firestore associé.
///
/// [StatutSession.nouveauCompte] signale un utilisateur authentifié par
/// SMS mais dont le document `users/{uid}` n'existe pas encore (première
/// connexion) : l'UI doit alors afficher l'écran de complétion de profil.
class SessionProvider extends ChangeNotifier {
  SessionProvider({
    AuthService? authService,
    UserService? userService,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService() {
    _authSubscription = _authService.authStateChanges.listen(_onAuthChange);
  }

  final AuthService _authService;
  final UserService _userService;

  late final StreamSubscription<User?> _authSubscription;
  StreamSubscription<UserModel?>? _userSubscription;

  StatutSession statut = StatutSession.chargement;
  UserModel? utilisateur;
  User? firebaseUser;

  AuthService get authService => _authService;
  UserService get userService => _userService;

  void _onAuthChange(User? user) {
    firebaseUser = user;
    _userSubscription?.cancel();

    if (user == null) {
      statut = StatutSession.deconnecte;
      utilisateur = null;
      notifyListeners();
      return;
    }

    _userSubscription = _userService.streamUtilisateur(user.uid).listen(
      (userModel) {
        utilisateur = userModel;
        statut = userModel == null
            ? StatutSession.nouveauCompte
            : StatutSession.connecte;
        notifyListeners();
      },
    );
  }

  Future<void> completerInscription({
    required String displayName,
    required String preferredLanguage,
  }) async {
    final user = firebaseUser;
    if (user == null) return;
    await _userService.creerUtilisateur(
      UserModel(
        uid: user.uid,
        phone: user.phoneNumber ?? '',
        displayName: displayName,
        preferredLanguage: preferredLanguage,
      ),
    );
  }

  Future<void> deconnexion() => _authService.deconnexion();

  @override
  void dispose() {
    _authSubscription.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
