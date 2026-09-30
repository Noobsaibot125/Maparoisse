import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../app_themes.dart';
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
      showAppNoticeDialog(
        context,
        message: "Veuillez sélectionner votre civilité.",
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
          Navigator.pushNamedAndRemoveUntil(
              context, '/dashboard', (route) => false);
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

  /// Seule sortie de cet écran : il n'a pas de bouton retour, et le profil
  /// reste inutilisable tant qu'il n'est pas finalisé.
  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthService>(context, listen: false).logout();
    } catch (e) {
      // La session locale est purgée quoi qu'il arrive : un appel réseau qui
      // échoue ne doit pas laisser l'utilisateur bloqué sur cet écran.
      debugPrint("Erreur pendant la déconnexion : $e");
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthService>(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Dernière étape",
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // PAS DE BOUTON RETOUR
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleLogout,
            child: Text(
              "Se déconnecter",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurface.withOpacity(0.55),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- EN-TÊTE CENTRÉ ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.12),
                    ),
                    child: Icon(
                      Icons.how_to_reg_rounded,
                      size: 44,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Finalisez votre inscription",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Ces informations nous permettent de vous joindre\nau sujet de vos demandes de messes.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    height: 1.5,
                    color: onSurface.withOpacity(0.6),
                  ),
                ),

                // --- RAPPEL DU COMPTE CONNECTÉ ---
                if (auth.email != null && auth.email!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Center(child: _buildAccountChip(context, auth)),
                ],

                const SizedBox(height: 36),

                // --- SÉLECTION CIVILITÉ ---
                _buildFieldLabel(context, "Civilité *"),
                Row(
                  children: [
                    // Libellés affichés ; les valeurs enregistrées restent
                    // 'M.' et 'Mme', comme à l'inscription classique.
                    _buildCiviliteOption(
                      value: 'M.',
                      label: "Homme",
                      icon: Icons.male,
                    ),
                    const SizedBox(width: 14),
                    _buildCiviliteOption(
                      value: 'Mme',
                      label: "Femme",
                      icon: Icons.female,
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // --- CHAMP TÉLÉPHONE ---
                _buildFieldLabel(context, "Numéro de téléphone *"),
                PhoneInputField(
                  controller: _phoneCtrl,
                  selectedCountry: _selectedCountry,
                  onCountryChanged: (c) =>
                      setState(() => _selectedCountry = c),
                  hintText: "Ex: 07 08 32 50 27",
                  validator: (val) => (val == null || val.trim().length < 8)
                      ? "Numéro invalide"
                      : null,
                ),

                const SizedBox(height: 40),

                // --- BOUTON VALIDER ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.primaryColor.withOpacity(0.5),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Terminer et accéder",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Rappelle avec quel compte social l'utilisateur est en train de s'inscrire.
  Widget _buildAccountChip(BuildContext context, AuthService auth) {
    final theme = Theme.of(context);
    final bool hasPhoto =
        auth.photoPath != null && auth.photoPath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
            backgroundImage: hasPhoto ? NetworkImage(auth.photoPath!) : null,
            child: hasPhoto
                ? null
                : Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              auth.email!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 2),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCiviliteOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final bool selected = _civilite == value;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _civilite = value),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor.withOpacity(0.10)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: selected ? AppTheme.primaryColor : theme.dividerColor,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: selected
                    ? AppTheme.primaryColor
                    : theme.colorScheme.onSurface.withOpacity(0.45),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppTheme.primaryColor
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
