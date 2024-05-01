import 'package:flutter/material.dart';

import '../models/models.dart';

class SelectedChannelController extends ChangeNotifier {
  Channel? _currentChannel;
  Channel? _previousChannel;

  Channel? get currentChannel => _currentChannel;
  Channel? get previousChannel => _previousChannel;

  set currentChannel(Channel? channel) {
    print("Setting selected channel id to $channel.");
    _previousChannel = _currentChannel;
    _currentChannel = channel;
    notifyListeners();
  }
}