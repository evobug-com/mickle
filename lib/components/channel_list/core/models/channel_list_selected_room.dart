import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/models.dart';

class ChannelListSelectedRoom extends ChangeNotifier {
  Channel? _selectedChannel;

  Channel? get selectedChannel => _selectedChannel;

  set selectedChannel(Channel? channel) {
    _selectedChannel = channel;
    print("[ChannelListSelectedRoom] Selected channel changed to ${channel?.name}");
    notifyListeners();
  }

  static ChannelListSelectedRoom of(BuildContext context, {bool listen = true}) {
    return Provider.of<ChannelListSelectedRoom>(context, listen: listen);
  }
}