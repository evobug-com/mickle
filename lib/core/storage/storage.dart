import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class Storage {
  static Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal();

  late GetStorage storage;

  Future<void> write(String key, String value) async {
    print("Writing to storage: $key -> $value");
    storage.write(key, value);
  }

  Future<String?> read(String key) async {
    return storage.read(key);
  }

  Future<bool> containsKey(String key) async {
    return storage.hasData(key);
  }

  Future<void> delete(String key) async {
    storage.remove(key);
  }

  static init() async {
    String path = (await getApplicationSupportDirectory()).path;
    print("Storage path: $path");
    Storage._instance.storage = GetStorage("siocom_talk", path);
    await Storage._instance.storage.initStorage;
  }
}