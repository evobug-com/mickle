import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

final _logger = Logger('Storage');

class Storage {
  static Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal();

  late GetStorage storage;

  Future<void> write(String key, String value) async {
    _logger.fine('Writing to storage: $key -> $value');
    storage.write(key, value);
  }

  String? read(String key) {
    final result = storage.read(key);
    _logger.fine('Reading from storage: $key -> $result');
    return result;
  }

  bool containsKey(String key) {
    return storage.hasData(key);
  }

  void delete(String key) {
    _logger.fine('Deleting from storage: $key');
    storage.remove(key);
  }

  static init() async {
    String path = (await getApplicationSupportDirectory()).path;
    _logger.fine("Storage path: $path");
    Storage._instance.storage = GetStorage("siocom_talk", path);
    await Storage._instance.storage.initStorage;
  }

  bool readBoolean(String key, {required bool defaultValue}) {
    final value = storage.read(key);
    if (value == null) {
      return defaultValue;
    }
    return value == "true" || value == '1' || value == 'yes' || value == 'on' || value == 'enabled' || value == 'active';
  }

  String readString(String key, {required String defaultValue}) {
    final value = storage.read(key);
    if (value == null) {
      return defaultValue;
    }
    return value;
  }
}