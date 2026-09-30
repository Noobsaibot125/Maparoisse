import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/l10n/app_localizations.dart';
import '../../app_themes.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profil',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
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

          // Contenu du profil
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- 1. EN-TÊTE DU PROFIL ---
                  _buildProfileHeader(context, auth),

                  const SizedBox(height: 24),

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
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                      if (!auth.isSocialUser) ...[
                        const Divider(height: 1),
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

                  const SizedBox(height: 30),

                  // --- 3. BOUTON SE DÉCONNECTER ---
                  ElevatedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _logoutButtonColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                    child: Text(
                      l10n.settingsLogoutButton,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Carte avec les informations utilisateur ---
  Widget _buildProfileHeader(BuildContext context, AuthService auth) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                backgroundImage: (auth.photoPath != null && auth.photoPath!.isNotEmpty)
                    ? NetworkImage(auth.photoPath!)
                    : null,
                child: (auth.photoPath == null || auth.photoPath!.isEmpty)
                    ? Icon(Icons.person, size: 36, color: AppTheme.primaryColor)
                    : null,
              ),
              if (auth.isBaptized)
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.water_drop_rounded, color: Colors.white, size: 10),
                        SizedBox(width: 2),
                        Text(
                          "BAPTISÉ",
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (auth.civilite != null && auth.civilite!.isNotEmpty)
                  Text(
                    auth.civilite!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  auth.fullName?.isNotEmpty == true ? auth.fullName! : 'Utilisateur',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (auth.email != null && auth.email!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          auth.email!,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (auth.phone != null && auth.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          auth.phone!,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Carte pour regrouper les options ---
  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // --- Élément de menu cliquable ---
  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null) Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
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
              foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
