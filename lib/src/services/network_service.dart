import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service surveillant en temps réel l'état de la connexion Internet
class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  bool _isOnline = true;
  bool _hasCheckedInitially = false;
  Timer? _timer;
  bool _isChecking = false;

  bool get isOnline => _isOnline;
  bool get hasCheckedInitially => _hasCheckedInitially;

  /// Initialise la vérification périodique du réseau
  void init() {
    if (_timer != null) return;
    checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => checkConnection());
  }

  /// Vérifie activement si une connexion réelle vers Internet est disponible
  Future<bool> checkConnection() async {
    if (_isChecking) return _isOnline;
    _isChecking = true;

    bool online = false;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      online = false;
    } on TimeoutException catch (_) {
      online = false;
    } catch (_) {
      online = false;
    } finally {
      _isChecking = false;
    }

    _updateStatus(online);
    return online;
  }

  /// Appelé immédiatement lorsqu'une requête API échoue pour cause réseau
  void setOffline() {
    _updateStatus(false);
  }

  /// Appelé immédiatement lorsqu'une requête API réussit
  void setOnline() {
    _updateStatus(true);
  }

  void _updateStatus(bool online) {
    if (!_hasCheckedInitially) {
      _hasCheckedInitially = true;
      _isOnline = online;
      notifyListeners();
      return;
    }

    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
