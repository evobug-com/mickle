import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

final _logger = Logger('SecureStorage');

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    _logger.fine('Writing to secure storage: $key -> $value');
    await _storage.write(key: key, value: value);
    _logger.fine('Wrote to secure storage: $key -> ${await read(key)}');
  }

  Future<String?> read(String key) async {
    final result = await _storage.read(key: key);
    _logger.fine('Reading from secure storage: $key -> $result');
    return result;
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<void> delete(String key) async {
    _logger.fine('Deleting from secure storage: $key');
    await _storage.delete(key: key);
  }

  static init() async {
    // No need to initialize anything
  }
}