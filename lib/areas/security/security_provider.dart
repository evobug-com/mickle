import 'package:flutter/foundation.dart';

class SecurityWarning {
  final String connectionUrl;
  final String message;
  void Function(SecurityWarning) onProceed;
  void Function(SecurityWarning) onDismiss;

  SecurityWarning(this.connectionUrl, this.message, {required this.onProceed, required this.onDismiss});
}

class SecurityWarningsProvider with ChangeNotifier {
  static final SecurityWarningsProvider _instance = SecurityWarningsProvider._internal();

  factory SecurityWarningsProvider() {
    return _instance;
  }

  SecurityWarningsProvider._internal();

  final List<SecurityWarning> _warnings = [];

  List<SecurityWarning> get warnings => List.unmodifiable(_warnings);

  void addWarning(SecurityWarning warning) {
    _warnings.add(warning);
    notifyListeners();
  }

  void removeWarning(String connectionUrl) {
    _warnings.removeWhere((w) => w.connectionUrl == connectionUrl);
    notifyListeners();
  }

  void clearWarnings() {
    _warnings.clear();
    notifyListeners();
  }
}