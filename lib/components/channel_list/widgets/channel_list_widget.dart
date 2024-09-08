import 'package:flutter/material.dart';
import 'package:talk/components/channel_list/components/channel_list_item.dart';
import 'package:talk/components/channel_list/components/channel_list_room_dialog.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/models/utils.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';

class ChannelListWidget extends StatefulWidget {
  final ConnectionProvider connection;
  final Server server;
  final void Function(Channel channel, String action) contextMenuHandler;
  const ChannelListWidget({super.key, required this.connection, required this.server, required this.contextMenuHandler});

  @override
  State<ChannelListWidget> createState() => _ChannelListWidgetState();
}

class _ChannelListWidgetState extends State<ChannelListWidget> {
  @override
  Widget build(BuildContext context) {
    final channels = widget.server.getChannelsForUser(widget.connection.user, database: widget.connection.database);

    return StreamBuilder(
      stream: widget.connection.database.channels.stream,
      initialData: channels,
      builder: (context, snapshot) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: channels.length,
                  itemBuilder: (BuildContext context, int index) {
                    final channel = channels[index];

                    return ListenableBuilder(
                      listenable: channel,
                      builder: (context, _) {
                        return ChannelListItem(
                            contextMenuHandler: widget.contextMenuHandler,
                            channel: channel,
                            user: widget.connection.user,
                            connection: widget.connection
                        );
                      }
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
                      onSubmitted: (title, description, isPrivate) async {
                        final result = await widget.connection.packetManager
                            .sendCreateChannel(
                                serverId: widget.server.id,
                                name: title,
                                description: description,
                                private: isPrivate
                        );
                        // TODO: Handle errors
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
    );
  }
}