import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/models/models.dart';
import '../connection/client.dart';
import '../database.dart';
import '../managers/packet_manager.dart';

final _logger = Logger('CurrentClientProvider');

@Deprecated('Use ConnectionProvider instead')
class CurrentClientProvider extends ChangeNotifier {
  static CurrentClientProvider? _instance;
  Client? _selectedClient;
  Client? get selectedClient => _selectedClient;
  Database? get database {
    if (_selectedClient == null) {
      return null;
    }
    return Database(_selectedClient!.serverId!);
  }
  PacketManager? get packetManager {
    if (_selectedClient == null) {
      throw Exception("No client selected");
    }
    return PacketManager(_selectedClient!);
  }

  CurrentClientProvider._();

  factory CurrentClientProvider() {
    _instance ??= CurrentClientProvider._();
    return _instance!;
  }

  void selectClient(Client client) {
    _logger.info('Selected client: ${client.serverId}');
    _selectedClient = client;
    notifyListeners();
  }

  void clearSelectedClient() {
    _selectedClient = null;
    notifyListeners();
  }

  static CurrentClientProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<CurrentClientProvider>(context, listen: listen);
  }

  User? get user => _selectedClient?.user;
  String? get userId => _selectedClient?.userId;
  Server? get server => _selectedClient?.server;
  String? get serverId => _selectedClient?.serverId;
  bool get isWelcomed => user != null && server != null;
}