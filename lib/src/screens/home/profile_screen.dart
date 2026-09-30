import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/l10n/app_localizations.dart';
import '../../app_themes.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import '../password_reset/forgot_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Couleur thématique turquoise pour le bouton déconnecter (identique aux paramètres)
  final Color _logoutButtonColor = const Color(0xFF68A4A3);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profil',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond transparente
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/background_jesus.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  // --- 1. IDENTITÉ ---
                  _buildProfileHeader(context, auth),

                  const SizedBox(height: 64),

                  // --- 2. SECTION COMPTE ---
                  _buildSettingsCard(
                    title: l10n.settingsAccountSectionTitle,
                    children: [
                      _buildSettingsItem(
                        icon: Icons.person_outline,
                        text: l10n.settingsEditProfile,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                      if (!auth.isSocialUser) ...[
                        Divider(
                          height: 1,
                          indent: 62,
                          color: theme.dividerColor,
                        ),
                        _buildSettingsItem(
                          icon: Icons.lock_outline,
                          text: l10n.settingsChangePassword,
                          onTap: () {
                            // Parcours OTP par SMS, verrouillé sur le numéro du
                            // compte connecté.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(
                                  restrictToCurrentAccount: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 28),

                  // --- 3. DÉCONNEXION ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text(
                        l10n.settingsLogoutButton,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _logoutButtonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- En-tête centré : photo, identité, coordonnées ---
  Widget _buildProfileHeader(BuildContext context, AuthService auth) {
    final theme = Theme.of(context);

    final String displayName =
        auth.fullName?.isNotEmpty == true ? auth.fullName! : 'Utilisateur';
    final String civilite = auth.civilite ?? '';

    // La civilité se lit naturellement devant le nom ("M. Jean Kouassi"),
    // plutôt qu'isolée sur sa propre ligne.
    final String title =
        civilite.isNotEmpty ? '$civilite $displayName' : displayName;

    final bool hasPhoto =
        auth.photoPath != null && auth.photoPath!.isNotEmpty;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.cardTheme.color,
                boxShadow: AppTheme.cardShadow,
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                backgroundImage: hasPhoto ? NetworkImage(auth.photoPath!) : null,
                child: hasPhoto
                    ? null
                    : Icon(Icons.person,
                        size: 52, color: AppTheme.primaryColor),
              ),
            ),
            if (auth.isBaptized)
              Positioned(
                bottom: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.water_drop_rounded,
                          color: Colors.white, size: 11),
                      SizedBox(width: 4),
                      Text(
                        "BAPTISÉ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        // Le badge déborde de l'avatar : on compense pour garder l'espacement.
        SizedBox(height: auth.isBaptized ? 26 : 18),

        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 14),

        if (auth.email != null && auth.email!.isNotEmpty)
          _buildContactLine(context, Icons.email_outlined, auth.email!),

        if (auth.phone != null && auth.phone!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildContactLine(context, Icons.phone_outlined, auth.phone!),
        ],
      ],
    );
  }

  // --- Ligne de coordonnée centrée (icône + valeur) ---
  Widget _buildContactLine(BuildContext context, IconData icon, String value) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 14.5, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- Section : intitulé discret au-dessus d'une carte groupant les options ---
  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.cardShadow,
          ),
          // Le clip garde l'effet d'appui dans les coins arrondis.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  // --- Élément de menu cliquable ---
  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  // --- Boîte de dialogue de déconnexion ---
  void _showLogoutDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 20,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.drawerLogoutTitle,
              style: GoogleFonts.cormorantGaramond(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.drawerLogoutMessage,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            child: Text(
              l10n.drawerLogoutCancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.drawerLogoutConfirm,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.logout();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
