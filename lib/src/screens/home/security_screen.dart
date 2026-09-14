import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/logo_widget.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPassCtrl.text.trim() != _confirmPassCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Les nouveaux mots de passe ne correspondent pas"),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.changePassword(
        oldPassword: _currentPassCtrl.text.trim(),
        newPassword: _newPassCtrl.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text("Mot de passe mis à jour avec succès"),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.of(context).pop(); // retourne à la page précédente
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Échec de la mise à jour. Vérifiez votre mot de passe actuel."),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue : $e"),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
        title: const Text(
          "Sécurité",
          style: TextStyle(
            color: Colors.white, // 👈 garde le titre en blanc
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const SanctaMissaLogo(),
              const SizedBox(height: 20),
              ModernCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Mot de passe actuel
                      TextFormField(
                        controller: _currentPassCtrl,
                        obscureText: _obscureCurrentPassword,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Mot de passe actuel",
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Requis" : null,
                      ),
                      const SizedBox(height: 16),

                      // Nouveau mot de passe
                      TextFormField(
                        controller: _newPassCtrl,
                        obscureText: _obscureNewPassword,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Nouveau mot de passe",
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? "Min. 6 caractères" : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirmer le mot de passe
                      TextFormField(
                        controller: _confirmPassCtrl,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Confirmer le mot de passe",
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Requis";
                          if (v != _newPassCtrl.text) return "Les mots de passe ne correspondent pas";
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : PrimaryButton(
                              text: "Mettre à jour",
                              onPressed: _updatePassword,
                              minimumSize: const Size.fromHeight(50),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}