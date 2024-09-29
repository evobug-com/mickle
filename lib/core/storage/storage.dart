import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _logger = Logger('Storage');

@immutable
class Storage implements SharedPreferencesAsync {
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal();
  String _prefix = '';

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  static init({required String prefix}) async {
    _instance._prefix = prefix;
  }

  @override
  Future<void> clear({Set<String>? allowList}) {
    return asyncPrefs.clear(allowList: allowList);
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) {
    return asyncPrefs.getAll(allowList: allowList);
  }

  @override
  Future<bool?> getBool(String key) {
    key = '$_prefix$key';
    return asyncPrefs.getBool(key);
  }

  @override
  Future<double?> getDouble(String key) {
    key = '$_prefix$key';
    return asyncPrefs.getDouble(key);
  }

  @override
  Future<int?> getInt(String key) {
    key = '$_prefix$key';
    return asyncPrefs.getInt(key);
  }

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) {
    return asyncPrefs.getKeys(allowList: allowList);
  }

  @override
  Future<List<String>?> getStringList(String key) {
    key = '$_prefix$key';
    return asyncPrefs.getStringList(key);
  }

  @override
  Future<void> remove(String key) {
    key = '$_prefix$key';
    return asyncPrefs.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) {
    key = '$_prefix$key';
    return asyncPrefs.setBool(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    key = '$_prefix$key';
    return asyncPrefs.setDouble(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    key = '$_prefix$key';
    return asyncPrefs.setInt(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    key = '$_prefix$key';
    return asyncPrefs.setStringList(key, value);
  }

  @override
  Future<bool> containsKey(String key) {
    key = '$_prefix$key';
    return asyncPrefs.containsKey(key);
  }

  @override
  Future<String?> getString(String key) {
    key = '$_prefix$key';
    return asyncPrefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) {
    key = '$_prefix$key';
    return asyncPrefs.setString(key, value);
  }
}