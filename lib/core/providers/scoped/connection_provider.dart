import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:talk/core/models/models.dart';

class ConnectionProvider extends ChangeNotifier {
  late Client client;
  late User user;
  late Server server;
  late Database database;
  late PacketManager packetManager;

  ConnectionProvider(this.client) {
    user = client.serverData.user!;
    server = client.serverData.server!;
    database = Database(client.serverData.serverId!);
    packetManager = PacketManager(client);
  }

  update(Client client) {
    this.client = client;
    user = client.serverData.user!;
    server = client.serverData.server!;
    database = Database(client.serverData.serverId!);
    packetManager = PacketManager(client);
    notifyListeners();
  }

  static ConnectionProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<ConnectionProvider>(context, listen: listen);
  }
}