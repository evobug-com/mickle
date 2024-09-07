import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:talk/areas/connection/connection.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:talk/core/models/models.dart';

import '../../../areas/connection/connection_status.dart';

class ConnectionProvider extends ChangeNotifier {
  late Connection? connection;
  User get user => connection!.currentUser!;
  Server get server => connection!.mainServer!;
  Database get database => connection!.database;
  PacketManager get packetManager => connection!.packetManager;

  ConnectionProvider(this.connection);

  update(Connection? connection) {
    this.connection = connection;
    notifyListeners();
  }

  get isClientConnected {
    return connection != null;
  }

  get isAuthedAndConnected {
    return connection != null && (connection?.status.value ?? ConnectionStatus.disconnected) == ConnectionStatus.authenticated;
  }

  static ConnectionProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<ConnectionProvider>(context, listen: listen);
  }

  static ConnectionProvider? maybeOf(BuildContext context, {bool listen = true}) {
    return Provider.of<ConnectionProvider?>(context, listen: listen);
  }
}