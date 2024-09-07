import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/areas/connection/connection.dart';
import 'package:talk/core/storage/preferences.dart';


class SelectedServerProvider extends ChangeNotifier {
  Connection? connection;

  SelectedServerProvider({this.connection});

  void selectServer(Connection? connection) {
    this.connection = connection;
    notifyListeners();

    if(connection != null) {
      // Save the selected server to the storage
      Preferences.setLastVisitedServerId(connection.mainServerId!);
    }
  }

  static SelectedServerProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<SelectedServerProvider>(context, listen: listen);
  }
}