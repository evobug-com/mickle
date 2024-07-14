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

  static Future<void> addServer({required String serverId, required String host, required String token, required String userId, required int port}) async {
    final servers = (await SecureStorage().readJSONArray("servers")) as List<dynamic>;
    final server = servers.firstWhereOrNull((server) => server["serverId"] == serverId && server["host"] == host);
    if (server != null) {
      servers.remove(server);
    }

    servers.add({
      "serverId": serverId,
      "host": host,
      "token": token,
      "userId": userId,
      "port": port
    });
    return SecureStorage().writeJSONArray("servers", servers);
  }

  static Future<void> removeServer(String serverId) {
    final servers = SecureStorage().readJSONArray("servers");
    servers.removeWhere((server) => server["serverId"] == serverId);
    return SecureStorage().write("servers", servers);
  }

  static getServerList() {
    return SecureStorage().readJSONArray("servers");
  }

  static bool getIsServerListExpanded() {
    return Storage().readBool("isServerListExpanded", defaultValue: false);
  }

  static void setIsServerListExpanded(bool isExpanded) {
    Storage().writeBool("isServerListExpanded", isExpanded);
  }
}