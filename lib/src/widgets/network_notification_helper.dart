import 'package:flutter/material.dart';
import 'package:maparoisse/src/app.dart';

/// Helper pour afficher des notifications élégantes et modernes d'état réseau
class NetworkNotificationHelper {
  static DateTime? _lastOfflineNoticeTime;
  static DateTime? _lastOnlineNoticeTime;

  /// Affiche le message moderne et soigné lors de la perte de connexion
  static void showOffline([BuildContext? context]) {
    final now = DateTime.now();
    // Évite de spammer si plusieurs requêtes échouent en même temps
    if (_lastOfflineNoticeTime != null &&
        now.difference(_lastOfflineNoticeTime!).inSeconds < 4) {
      return;
    }
    _lastOfflineNoticeTime = now;

    final messenger = context != null
        ? ScaffoldMessenger.maybeOf(context) ?? scaffoldMessengerKey.currentState
        : scaffoldMessengerKey.currentState;

    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final snackBar = SnackBar(
      elevation: 8,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: const Color(0xFF1E293B), // Ardoise foncée moderne
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFEF4444).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      duration: const Duration(seconds: 4),
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Connexion Internet perdue",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Vérifiez votre réseau mobile ou Wi-Fi.",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    messenger.showSnackBar(snackBar);
  }

  /// Affiche le message moderne et soigné lorsque la connexion est rétablie
  static void showOnline([BuildContext? context]) {
    final now = DateTime.now();
    if (_lastOnlineNoticeTime != null &&
        now.difference(_lastOnlineNoticeTime!).inSeconds < 4) {
      return;
    }
    _lastOnlineNoticeTime = now;

    final messenger = context != null
        ? ScaffoldMessenger.maybeOf(context) ?? scaffoldMessengerKey.currentState
        : scaffoldMessengerKey.currentState;

    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final snackBar = SnackBar(
      elevation: 8,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: const Color(0xFF0F291E), // Vert sombre émeraude
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF10B981).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.wifi_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Connexion rétablie",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Vous êtes de nouveau en ligne.",
                  style: TextStyle(
                    color: Color(0xFFA7F3D0),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    messenger.showSnackBar(snackBar);
  }
}
