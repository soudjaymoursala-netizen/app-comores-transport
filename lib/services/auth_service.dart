import 'package:firebase_auth/firebase_auth.dart';

/// Encapsule le flux Firebase Phone Auth (envoi du SMS + vérification du
/// code). Ne gère pas la création du document Firestore associé : voir
/// [UserService] pour la persistance du profil utilisateur.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  /// Lance l'envoi du code SMS vers [numeroTelephone] (format E.164, ex.
  /// "+2693312345"). Sur Android, une vérification automatique peut
  /// aboutir sans saisie de code (`onAutoVerificationCompleted`) : dans ce
  /// cas [onVerificationCompleted] connecte directement l'utilisateur.
  Future<void> envoyerCodeSms({
    required String numeroTelephone,
    required void Function(String verificationId) onCodeEnvoye,
    required void Function(FirebaseAuthException erreur) onEchec,
    required void Function(UserCredential credential)
        onVerificationAutomatique,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: numeroTelephone,
      timeout: timeout,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        onVerificationAutomatique(userCredential);
      },
      verificationFailed: onEchec,
      codeSent: (String verificationId, int? forceResendingToken) {
        onCodeEnvoye(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Valide le code SMS saisi par l'utilisateur et termine la connexion.
  Future<UserCredential> confirmerCodeSms({
    required String verificationId,
    required String codeSaisi,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: codeSaisi,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> deconnexion() => _firebaseAuth.signOut();
}
