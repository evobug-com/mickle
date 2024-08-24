import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/models.dart';

class ChannelListSelectedChannel extends ChangeNotifier {
  Map<Server, Channel?> _selectedChannelByServer = {};

  setChannel(Server server, Channel? channel) {
    _selectedChannelByServer[server] = channel;
    print("[ChannelListSelectedRoom] Selected channel changed to ${channel?.name} for server ${server.name}");
    notifyListeners();
  }

  getChannel(Server server) {
    return _selectedChannelByServer[server];
  }

  static ChannelListSelectedChannel of(BuildContext context, {bool listen = true}) {
    return Provider.of<ChannelListSelectedChannel>(context, listen: listen);
  }
}