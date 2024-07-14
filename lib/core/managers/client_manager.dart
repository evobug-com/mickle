
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/managers/reconnect_manager.dart';

import '../storage/secure_storage.dart';
import '../connection/client.dart';

class ClientManager extends ChangeNotifier {
  final LinkedHashMap<String, Client> _clients = LinkedHashMap();
  final ReconnectManager _reconnectManager = ReconnectManager();
  static ClientManager? _instance;

  ClientManager._();

  factory ClientManager() {
    _instance ??= ClientManager._();
    return _instance!;
  }

  void addClient(Client client) {
    if (!_clients.containsKey(client.address.toString())) {
      _clients[client.address.toString()] = client;
      _reconnectManager.enableReconnection(client);
      notifyListeners();

      if(client.serverId != null) {
        _addClientToStorage(client);
      }
    }
  }

  void removeClient(Client client) {
    if (_clients.containsKey(client.address.toString())) {
      _clients.remove(client.address.toString());
      _reconnectManager.disableReconnection(client);
      notifyListeners();

      _removeClientFromStorage(client);
    }
  }

  void _addClientToStorage(Client client) async {
    assert(client.serverId != null);

    List<dynamic> servers = jsonDecode(await SecureStorage().read("servers") ?? "[]");

    if(!servers.contains(client.serverId)) {
      servers.add(client.serverId!);
    }

    // Save the updated list
    await SecureStorage().write("servers", jsonEncode(servers));
  }

  void _removeClientFromStorage(Client client) async {
    List<dynamic> servers = jsonDecode(await SecureStorage().read("servers") ?? "[]");

    // Remove the server from the list
    servers.removeWhere((server) => server == client.serverId);

    // Save the updated list
    await SecureStorage().write("servers", jsonEncode(servers));
  }

  Iterable<Client> get clients => _clients.values;

  static ClientManager of(BuildContext context, {bool listen = true}) {
    return Provider.of<ClientManager>(context, listen: listen);
  }

  void toggleReconnection(Client client, bool value) {
    if (value) {
      _reconnectManager.enableReconnection(client);
    } else {
      _reconnectManager.disableReconnection(client);
    }
  }

  void onConnectionLost(Client client) {
    _reconnectManager.onConnectionLost(client);
  }
}