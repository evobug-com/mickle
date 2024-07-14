import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/storage/preferences.dart';

import '../../connection/client.dart';

class SelectedServerProvider extends ChangeNotifier {
  String? host;
  int? port;
  String? serverId;
  Client? client;

  SelectedServerProvider({this.host, this.port, this.serverId, this.client});

  void selectServer(String host, int port, String serverId, Client? client) {
    this.host = host;
    this.port = port;
    this.serverId = serverId;
    this.client = client;
    notifyListeners();

    // Save the selected server to the storage
    Preferences.setLastVisitedServerId(serverId);
  }

  static SelectedServerProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<SelectedServerProvider>(context, listen: listen);
  }
}