import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:talk/core/storage/secure_storage.dart';

import 'storage.dart';

class Preferences {
  static String getLastVisitedServerId() {
    return Storage().readString("lastVisitedServerId", defaultValue: "");
  }

  static void setLastVisitedServerId(String serverId) {
    Storage().write("lastVisitedServerId", serverId);
  }

  static bool getIsServerListExpanded() {
    return Storage().readBool("isServerListExpanded", defaultValue: false);
  }

  static void setIsServerListExpanded(bool isExpanded) {
    Storage().writeBool("isServerListExpanded", isExpanded);
  }

  static bool isFirstTime() {
    return Storage().readBool("isFirstTime", defaultValue: true);
  }

  static void setFirstTime(bool isFirstTime) {
    Storage().writeBool("isFirstTime", isFirstTime);
  }
}