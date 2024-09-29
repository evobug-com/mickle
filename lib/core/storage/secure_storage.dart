
import 'dart:convert';
import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:mickle/core/storage/encrypt_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage.dart';

final _logger = Logger('SecureStorage');

// TODO: Find a way how to store the encryption key securely
final String encryptionKey = base64.encode(utf8.encode('encryptionKey'));

@immutable
class SecureStorage implements SharedPreferencesAsync {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  late final EncryptedSharedPreferences asyncEncryptedPrefs;

  static init() async {
    if(!(await Storage().containsKey(encryptionKey))) {
      final newEncryptionKey = List.generate(16, (index) => Random.secure().nextInt(9)).join();
      await Storage().setString(encryptionKey, base64.encode(utf8.encode(newEncryptionKey)));
    }

    _instance.asyncEncryptedPrefs = EncryptedSharedPreferences(
      preferences: SharedPreferencesAsync(),
      key: utf8.decode(base64.decode((await Storage().getString(encryptionKey))!)),
    );
  }

  @override
  Future<void> clear({Set<String>? allowList}) {
    return asyncEncryptedPrefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return asyncEncryptedPrefs.containsKey(key);
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) {
    return asyncEncryptedPrefs.getAll(allowList: allowList);
  }

  @override
  Future<bool?> getBool(String key) async {
    return asyncEncryptedPrefs.getBool(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    return asyncEncryptedPrefs.getDouble(key);
  }

  @override
  Future<int?> getInt(String key) async {
    return asyncEncryptedPrefs.getInt(key);
  }

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) {
    return asyncEncryptedPrefs.getKeys(allowList: allowList);
  }

  @override
  Future<String?> getString(String key) async {
    return asyncEncryptedPrefs.getString(key);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return asyncEncryptedPrefs.getStringList(key);
  }

  @override
  Future<void> remove(String key) {
    return asyncEncryptedPrefs.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) {
    return asyncEncryptedPrefs.setBool(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    return asyncEncryptedPrefs.setDouble(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    return asyncEncryptedPrefs.setInt(key, value);
  }

  @override
  Future<void> setString(String key, String value) {
    return asyncEncryptedPrefs.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    return asyncEncryptedPrefs.setStringList(key, value);
  }
}