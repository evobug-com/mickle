
import 'package:flutter/material.dart';

import '../core/generic_channel_list.dart';
import '../core/models/models.dart';
import '../core/notifiers/selected_channel_controller.dart';


class ChannelList extends StatelessWidget {
  final SelectedChannelController controller;
  final List<Channel> channels;

  const ChannelList({super.key, required this.controller, required this.channels});

  @override
  Widget build(BuildContext context) {
    return GenericRoomList(
      itemCount: channels.length,
      titleBuilder: (index) => channels[index].name ?? '<Unnamed Room>',
      controller: controller,
      onRoomSelected: (index) {
        controller.currentChannel = channels[index];
      },
      getRoomUid: (index) => channels[index].id,
    );
  }
}

class PrivateChannelList extends StatelessWidget {
  final SelectedChannelController controller;
  final List<Channel> channels;

  const PrivateChannelList({super.key, required this.controller, required this.channels});

  @override
  Widget build(BuildContext context) {
    return GenericRoomList(
      itemCount: channels.length,
      titleBuilder: (index) => channels[index].name ?? '<Unnamed Private Room>',
      controller: controller,
      onRoomSelected: (index) {
        controller.currentChannel = channels[index];
      },
      getRoomUid: (index) => channels[index].id,
    );
  }
}