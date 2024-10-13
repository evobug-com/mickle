
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
  String _prefix = '';

  static init({required String prefix}) async {
    _instance._prefix = prefix;

    if(!(await Storage().containsKey(prefix + encryptionKey))) {
      final newEncryptionKey = List.generate(16, (index) => Random.secure().nextInt(9)).join();
      await Storage().setString(prefix + encryptionKey, base64.encode(utf8.encode(newEncryptionKey)));
    }

    final encryption = utf8.decode(base64.decode((await Storage().getString(prefix + encryptionKey))!));

    _instance.asyncEncryptedPrefs = EncryptedSharedPreferences(
      preferences: SharedPreferencesAsync(),
      key: encryption
    );
  }

  @override
  Future<void> clear({Set<String>? allowList}) {
    return asyncEncryptedPrefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.containsKey(key);
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) {
    return asyncEncryptedPrefs.getAll(allowList: allowList);
  }

  @override
  Future<bool?> getBool(String key) async {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.getBool(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.getDouble(key);
  }

  @override
  Future<int?> getInt(String key) async {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.getInt(key);
  }

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) {
    return asyncEncryptedPrefs.getKeys(allowList: allowList);
  }

  @override
  Future<String?> getString(String key) async {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.getString(key);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.getStringList(key);
  }

  @override
  Future<void> remove(String key) {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.setBool(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.setDouble(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.setInt(key, value);
  }

  @override
  Future<void> setString(String key, String value) {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    key = "$_prefix$key";
    return asyncEncryptedPrefs.setStringList(key, value);
  }
}