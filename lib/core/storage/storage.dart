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

  Future<String?> read(String key) async {
    final result = storage.read(key);
    _logger.fine('Reading from storage: $key -> $result');
    return result;
  }

  Future<bool> containsKey(String key) async {
    return storage.hasData(key);
  }

  Future<void> delete(String key) async {
    _logger.fine('Deleting from storage: $key');
    storage.remove(key);
  }

  static init() async {
    String path = (await getApplicationSupportDirectory()).path;
    _logger.fine("Storage path: $path");
    Storage._instance.storage = GetStorage("siocom_talk", path);
    await Storage._instance.storage.initStorage;
  }
}