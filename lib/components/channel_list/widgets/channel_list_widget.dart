import 'package:flutter/material.dart';
import 'package:talk/components/channel_list/components/channel_list_item.dart';
import 'package:talk/components/channel_list/components/channel_list_room_dialog.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/processor/packet_manager.dart';

class ChannelListWidget extends StatefulWidget {
  final Client client;
  final Server server;
  final void Function(Channel channel, String action) contextMenuHandler;
  const ChannelListWidget({super.key, required this.client, required this.server, required this.contextMenuHandler});

  @override
  State<ChannelListWidget> createState() => _ChannelListWidgetState();
}

class _ChannelListWidgetState extends State<ChannelListWidget> {
  @override
  Widget build(BuildContext context) {
    final channels = widget.server.getChannelsForUser(widget.client.user!);
    final packetManager = PacketManager(widget.client);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (BuildContext context, int index) {
                final channel = channels[index];

                return ChannelListItem(
                    contextMenuHandler: widget.contextMenuHandler,
                    channel: channel,
                    user: widget.client.user!
                );
              }
          )
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // Show dialog to create a new channel
            showDialog(
              context: context,
              builder: (context) {
                return ChannelListRoomDialog(
                  onSubmitted: (title, description, isPrivate) {
                    packetManager.sendChannelCreate(serverId: widget.server.id, name: title, description: description);
                  },
                  isEdit: false,
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
      ]
    );
  }
}