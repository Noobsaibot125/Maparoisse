import 'package:flutter/material.dart';
import 'package:maparoisse/l10n/app_localizations.dart';
import 'package:maparoisse/src/app_themes.dart';

/// Popup d'information partagé par les écrans d'authentification.
///
/// Remplace les SnackBars pour les messages qui doivent être lus avant de
/// continuer (numéro refusé, compte lié à Google, code expiré...).
Future<void> showAppNoticeDialog(
  BuildContext context, {
  required String message,
  String? title,
  IconData icon = Icons.error_outline,
  Color? iconColor,
}) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;
  final Color accent = iconColor ?? AppTheme.errorColor;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: accent),
          ),
          const SizedBox(height: 20),
          Text(
            title ?? l10n.dialogNoticeTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            l10n.close,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
