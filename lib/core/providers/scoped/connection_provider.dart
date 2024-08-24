import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:talk/core/models/models.dart';

class ConnectionProvider extends ChangeNotifier {
  late Client? client;
  late User user;
  late Server server;
  late Database database;
  late PacketManager packetManager;
  bool _isClientConnected = false;

  ConnectionProvider(this.client) {
    if (client != null) {
      user = client!.serverData.user!;
      server = client!.serverData.server!;
      database = Database(client!.serverData.serverId!);
      packetManager = PacketManager(client!);
      _isClientConnected = true;
    }
  }

  update(Client? client) {
    this.client = client;
    if (client != null) {
      user = client.serverData.user!;
      server = client.serverData.server!;
      database = Database(client.serverData.serverId!);
      packetManager = PacketManager(client);
      _isClientConnected = true;
    } else {
      _isClientConnected = false;
    }
    notifyListeners();
  }

  get isClientConnected {
    return _isClientConnected;
  }

  static ConnectionProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<ConnectionProvider>(context, listen: listen);
  }

  static ConnectionProvider? maybeOf(BuildContext context, {bool listen = true}) {
    return Provider.of<ConnectionProvider?>(context, listen: listen);
  }
}