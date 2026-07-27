import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/session_provider.dart';

/// Écran de saisie du code SMS reçu. La connexion Firebase Auth se
/// termine ici ; le [SessionProvider] prend ensuite le relais pour
/// vérifier si un document `users/{uid}` existe déjà (voir main.dart /
/// AuthGate) et router vers l'écran adapté.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.numeroTelephone,
  });

  final String verificationId;
  final String numeroTelephone;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _codeController = TextEditingController();
  bool _verificationEnCours = false;
  String? _messageErreur;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirmerCode() async {
    if (_codeController.text.trim().length < 6) {
      setState(() => _messageErreur = 'Le code contient 6 chiffres.');
      return;
    }

    setState(() {
      _verificationEnCours = true;
      _messageErreur = null;
    });

    final session = context.read<SessionProvider>();

    try {
      await session.authService.confirmerCodeSms(
        verificationId: widget.verificationId,
        codeSaisi: _codeController.text.trim(),
      );
      // La navigation post-connexion est gérée par l'AuthGate qui écoute
      // le SessionProvider : on ne fait rien de plus ici.
    } on FirebaseAuthException catch (erreur) {
      if (!mounted) return;
      setState(() {
        _messageErreur = erreur.code == 'invalid-verification-code'
            ? 'Code incorrect. Veuillez réessayer.'
            : erreur.message ?? 'Échec de la vérification.';
      });
    } finally {
      if (mounted) setState(() => _verificationEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entrez le code à 6 chiffres envoyé au '
              '${widget.numeroTelephone}.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            if (_messageErreur != null) ...[
              const SizedBox(height: 12),
              Text(_messageErreur!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _verificationEnCours ? null : _confirmerCode,
              child: _verificationEnCours
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
