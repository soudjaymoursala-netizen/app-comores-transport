import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/session_provider.dart';
import 'otp_verification_screen.dart';

/// Écran de saisie du numéro de téléphone (indicatif Comores +269 par
/// défaut) déclenchant l'envoi du code SMS via Firebase Phone Auth.
class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController(text: '+269');
  bool _envoiEnCours = false;
  String? _messageErreur;

  @override
  void dispose() {
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _envoiEnCours = true;
      _messageErreur = null;
    });

    final session = context.read<SessionProvider>();
    final numero = _numeroController.text.trim();

    await session.authService.envoyerCodeSms(
      numeroTelephone: numero,
      onCodeEnvoye: (verificationId) {
        if (!mounted) return;
        setState(() => _envoiEnCours = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              verificationId: verificationId,
              numeroTelephone: numero,
            ),
          ),
        );
      },
      onEchec: (FirebaseAuthException erreur) {
        if (!mounted) return;
        setState(() {
          _envoiEnCours = false;
          _messageErreur = erreur.message ?? 'Échec de l\'envoi du code SMS.';
        });
      },
      onVerificationAutomatique: (_) {
        // Connexion automatique effectuée par Firebase (Android uniquement).
        // Le SessionProvider réagira au changement d'état d'authentification.
        if (!mounted) return;
        setState(() => _envoiEnCours = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Entrez votre numéro de téléphone pour recevoir un code '
                'de vérification par SMS.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _numeroController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: '+2693312345',
                  border: OutlineInputBorder(),
                ),
                validator: (valeur) {
                  if (valeur == null ||
                      !RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(valeur.trim())) {
                    return 'Format attendu : +2693312345 (indicatif inclus)';
                  }
                  return null;
                },
              ),
              if (_messageErreur != null) ...[
                const SizedBox(height: 12),
                Text(
                  _messageErreur!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _envoiEnCours ? null : _envoyerCode,
                child: _envoiEnCours
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Recevoir le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
