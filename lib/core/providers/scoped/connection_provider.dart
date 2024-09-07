import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:talk/areas/connection/connection.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:talk/core/models/models.dart';

class ConnectionProvider extends ChangeNotifier {
  late Connection? connection;
  late User user;
  late Server server;
  late Database database;
  late PacketManager packetManager;
  bool _isClientConnected = false;

  ConnectionProvider(this.connection) {
    if (connection != null && connection!.currentUser != null) {
      user = connection!.currentUser!;
      server = connection!.mainServer!;
      database = connection!.database!;
      packetManager = connection!.packetManager;
      _isClientConnected = true;
    } else {
      _isClientConnected = false;
    }
  }

  update(Connection? connection) {
    this.connection = connection;
    if (connection != null && connection.currentUser != null) {
      user = connection.currentUser!;
      server = connection.mainServer!;
      database = connection.database!;
      packetManager = connection.packetManager;
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