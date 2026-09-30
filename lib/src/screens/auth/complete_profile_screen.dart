import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../app_themes.dart';
import '../widgets/modern_card.dart';
import '../widgets/primary_button.dart'; // Si tu l'as, sinon ElevatedButton
import '../../models/country.dart';
import '../../widgets/phone_input_field.dart';
import '../../widgets/app_notice_dialog.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  Country _selectedCountry = Country.defaultCountry;
  String? _civilite;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCompletion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_civilite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner votre civilité"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      // Endpoint dédié à la finalisation d'une inscription Google/Apple.
      // Format international obligatoire : c'est sous cette forme que les
      // numéros sont enregistrés à l'inscription classique. Sans cela,
      // "0708325027" et "+2250708325027" cohabiteraient en base comme deux
      // contacts distincts, et la contrainte d'unicité ne verrait rien.
      bool success = await auth.completeSocialProfile(
        contact: Country.formatFullPhone(_selectedCountry, _phoneCtrl.text),
        civilite: _civilite!,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          // 🎉 Profil complet ! Direction Dashboard
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        } else {
          showAppNoticeDialog(
            context,
            message: "Erreur lors de la mise à jour.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Message du serveur (ex: numéro déjà utilisé par un autre compte).
        showAppNoticeDialog(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color primaryColor = Color(0xFFC0A040);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Dernière étape", style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // PAS DE BOUTON RETOUR
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Finalisez votre inscription",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                "Nous avons besoin de ces informations pour traiter vos demandes de messes.",
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 32),

// --- SÉLECTION CIVILITÉ ---
              Text("Civilité *", style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ModernCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onTap: () => setState(() => _civilite = 'M.'),
                      borderColor: _civilite == 'M.' ? primaryColor : null,
                      backgroundColor: _civilite == 'M.' ? primaryColor.withOpacity(0.1) : theme.cardTheme.color,
                      child: Center(child: Text("Monsieur", style: TextStyle(fontWeight: FontWeight.w600, color: _civilite == 'M.' ? primaryColor : theme.colorScheme.onSurface))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onTap: () => setState(() => _civilite = 'Mme'),
                      borderColor: _civilite == 'Mme' ? primaryColor : null,
                      backgroundColor: _civilite == 'Mme' ? primaryColor.withOpacity(0.1) : theme.cardTheme.color,
                      child: Center(child: Text("Madame", style: TextStyle(fontWeight: FontWeight.w600, color: _civilite == 'Mme' ? primaryColor : theme.colorScheme.onSurface))),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- CHAMP TÉLÉPHONE ---
              PhoneInputField(
                controller: _phoneCtrl,
                selectedCountry: _selectedCountry,
                onCountryChanged: (c) => setState(() => _selectedCountry = c),
                hintText: "Ex: 07 08 32 50 27",
                validator: (val) =>
                    (val == null || val.trim().length < 8) ? "Numéro invalide" : null,
              ),

              const SizedBox(height: 40),

              // --- BOUTON VALIDER ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Terminer et Accéder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}