// Workaround until https://github.com/xaldarof/encrypted-shared-preferences/issues/9 is implemented

import 'dart:async';

import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AESEncryptor {
  String encrypt(String key, String plainText) {
    if (plainText.trim().isEmpty) return "";
    assert(key.length == 16);
    final cipherKey = Key.fromUtf8(key);
    final encryptService = Encrypter(AES(cipherKey));
    final initVector = IV.fromUtf8(key);

    Encrypted encryptedData = encryptService.encrypt(plainText, iv: initVector);
    return encryptedData.base64;
  }

  String decrypt(String key, String encryptedData) {
    if (encryptedData.trim().isEmpty) return "";
    assert(key.length == 16);
    final cipherKey = Key.fromUtf8(key);
    final encryptService = Encrypter(AES(cipherKey));
    final initVector = IV.fromUtf8(key);

    return encryptService.decrypt(Encrypted.fromBase64(encryptedData),
        iv: initVector);
  }
}

class EncryptedSharedPreferences implements SharedPreferencesAsync {
  final SharedPreferencesAsync _preferences;
  final String _key;
  final AESEncryptor _encryptor = AESEncryptor();

  EncryptedSharedPreferences({
    required SharedPreferencesAsync preferences,
    required String key,
  })  : _preferences = preferences,
        _key = key;
  

  @override
  Future<void> clear({Set<String>? allowList}) {
    return _preferences.clear(allowList: allowList);
  }

  @override
  Future<bool> containsKey(String key) {
    return _preferences.containsKey(_encryptor.encrypt(_key, key));
  }


  @override
  Future<bool?> getBool(String key) async {
    final value = await _preferences.getString(_encryptor.encrypt(_key, key));
    if (value == null) return null;
    return _encryptor.decrypt(_key, value) == "true";
  }

  @override
  Future<double?> getDouble(String key) async {
    final value = await _preferences.getString(_encryptor.encrypt(_key, key));
    if (value == null) return null;
    return double.parse(_encryptor.decrypt(_key, value));
  }

  @override
  Future<int?> getInt(String key) async {
    final value = await _preferences.getString(_encryptor.encrypt(_key, key));
    if (value == null) return null;
    return int.parse(_encryptor.decrypt(_key, value));

  }

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async {
    final set = await _preferences.getKeys(allowList: allowList);
    return set.map((item) {
      try {
        return _encryptor.decrypt(_key, item);
      } catch (e) {
        return item;
      }
    }).toSet();
  }

  @override
  Future<String?> getString(String key) async {
    final value = await _preferences.getString(_encryptor.encrypt(_key, key));
    if (value == null) return null;
    return _encryptor.decrypt(_key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final set = await _preferences.getStringList(_encryptor.encrypt(_key, key));
    return set?.map((e) => _encryptor.decrypt(_key, e)).toList();
  }

  @override
  Future<void> remove(String key) {
    return _preferences.remove(_encryptor.encrypt(_key, key));
  }

  @override
  Future<void> setBool(String key, bool? value) {
    return save(key, value);
  }

  @override
  Future<void> setDouble(String key, double? value) {
    return save(key, value);
  }

  @override
  Future<void> setInt(String key, int? value) {
    return save(key, value);
  }

  @override
  Future<void> setString(String key, String? value) {
    return save(key, value);
  }

  Future<void> save(String key, dynamic value) {
    var enKey = _encryptor.encrypt(_key, key);
    if (value == "") {
      return _preferences.setString(enKey, value);
    }
    return _preferences.setString(
        enKey, _encryptor.encrypt(_key, value.toString()));
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    return _preferences.setStringList(
        _encryptor.encrypt(_key, key),
        value.map((e) => _encryptor.encrypt(_key, e)).toList()
    );
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) {
    throw UnimplementedError();
  }
}