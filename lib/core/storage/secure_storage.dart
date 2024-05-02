import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    print("Writing to secure storage: $key -> $value");
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static init() async {
    // No need to initialize anything
  }
}