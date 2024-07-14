import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/storage/preferences.dart';

import '../../connection/client.dart';

class SelectedServerProvider extends ChangeNotifier {
  Client? client;

  SelectedServerProvider({this.client});

  void selectServer(Client? client) {
    this.client = client;
    notifyListeners();

    if(client != null) {
      // Save the selected server to the storage
      Preferences.setLastVisitedServerId(client.serverId!);
    }
  }

  static SelectedServerProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<SelectedServerProvider>(context, listen: listen);
  }
}