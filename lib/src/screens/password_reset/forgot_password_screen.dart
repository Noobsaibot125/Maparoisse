// lib/src/screens/password_reset/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/src/services/auth_service.dart';
import 'package:maparoisse/src/app_themes.dart';
import 'package:maparoisse/src/widgets/loader_widget.dart'; // Assure-toi que le chemin est bon
import 'package:maparoisse/src/widgets/app_notice_dialog.dart';
import '../../../l10n/app_localizations.dart';
import 'otp_verification_screen.dart';
import '../../models/country.dart';
import '../../widgets/phone_input_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  /// Quand `true`, seul le numéro du compte connecté est accepté : c'est le
  /// parcours ouvert depuis le profil. Depuis l'écran de connexion,
  /// l'utilisateur n'est pas identifié, donc tout numéro est permis.
  final bool restrictToCurrentAccount;

  const ForgotPasswordScreen({Key? key, this.restrictToCurrentAccount = false})
      : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

  class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
    final _formKey = GlobalKey<FormState>();
    final _phoneCtrl = TextEditingController();
    Country _selectedCountry = Country.defaultCountry;
    bool _isLoading = false;
  
    Future<void> _sendCode() async {
      final l10n = AppLocalizations.of(context)!;
  
      if (!_formKey.currentState!.validate()) return;

      final authService = Provider.of<AuthService>(context, listen: false);
      final fullPhone =
          Country.formatFullPhone(_selectedCountry, _phoneCtrl.text);

      // Parcours ouvert depuis le profil : on refuse tout numéro autre que
      // celui du compte connecté, sans même solliciter le serveur.
      if (widget.restrictToCurrentAccount &&
          !_isSameNumber(fullPhone, authService.phone)) {
        _showError(l10n.phoneNotCurrentAccount);
        return;
      }

      setState(() => _isLoading = true);

      try {
        final success = await authService.requestPasswordReset(fullPhone);

        if (!mounted) return;

        if (success) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(phone: fullPhone),
          ));
        } else {
          _showError(l10n.smsSendError);
        }
      } catch (e) {
        // Le service relaie le refus du serveur (numéro inconnu, compte lié à
        // Google, réseau indisponible...) : on affiche son message tel quel.
        if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    /// Compare deux numéros en ignorant l'indicatif et la mise en forme.
    bool _isSameNumber(String entered, String? account) {
      final a = entered.replaceAll(RegExp(r'\D'), '');
      final b = (account ?? '').replaceAll(RegExp(r'\D'), '');
      if (a.isEmpty || b.isEmpty) return false;
      return a == b || a.endsWith(b) || b.endsWith(a);
    }
  
  
  
    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
  
      final theme = Theme.of(context); // Raccourci pour le thème
  
      return Scaffold(
        // ✅ FOND DYNAMIQUE
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Réinitialisation", // Modifié pour correspondre au titre générique
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        ),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_android, size: 80, color: AppTheme.primaryColor),
                      const SizedBox(height: 20),
                      Text(
                        l10n.resetPassword,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            // ✅ TEXTE DYNAMIQUE
                            color: theme.colorScheme.onSurface
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Entrez votre numéro de téléphone pour recevoir un code de vérification.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // ✅ TEXTE SECONDAIRE DYNAMIQUE
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 40),
  
                      // ✅ CHAMP TELEPHONE AVEC INDICATIF
                      PhoneInputField(
                        controller: _phoneCtrl,
                        selectedCountry: _selectedCountry,
                        onCountryChanged: (c) => setState(() => _selectedCountry = c),
                        hintText: "Ex: 07 08 32 50 27",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Veuillez entrer votre numéro.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 50),
  
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.sendCode, style: const TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              // ✅ FOND DU LOADER DYNAMIQUE
              color: theme.scaffoldBackgroundColor.withOpacity(0.8),
              child: const CustomCircularLoader(), // Assure-toi que ton loader est visible sur fond noir
            ),
        ],
      ),
    );
  }


  void _showError(String message) {
    final bool isNetworkError =
        message.contains('Internet') || message.contains('connexion');

    showAppNoticeDialog(
      context,
      message: message,
      icon: isNetworkError ? Icons.wifi_off : Icons.error_outline,
      iconColor: isNetworkError ? Colors.grey.shade700 : null,
    );
  }
}