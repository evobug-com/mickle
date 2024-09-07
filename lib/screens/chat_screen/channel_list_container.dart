import 'package:flutter/material.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/models/utils.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';
import 'package:talk/screens/chat_screen/sidebar.dart';
import 'package:talk/screens/chat_screen/sidebar_box.dart';

import '../../components/channel_list/components/channel_list_room_dialog.dart';
import '../../components/channel_list/core/models/channel_list_selected_room.dart';
import '../../components/channel_list/widgets/channel_list_widget.dart';

class ChannelListContainer extends StatefulWidget {
  final ConnectionProvider connection;
  const ChannelListContainer({super.key, required this.connection});

  @override
  State<ChannelListContainer> createState() => _ChannelListContainerState();
}

class _ChannelListContainerState extends State<ChannelListContainer> {

  final TextEditingController _createChannelNameController =
  TextEditingController();
  final TextEditingController _createChannelDescriptionController =
  TextEditingController();

  @override
  void dispose() {
    _createChannelNameController.dispose();
    _createChannelDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SidebarBox(
            child: StreamBuilder(
              stream: widget.connection.database.channels.stream,
              initialData: widget.connection.server.getChannels(database: widget.connection.database),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ChannelListWidget(
                    connection: widget.connection,
                    server: widget.connection.server,
                    contextMenuHandler: (channel, action) {
                      switch (action) {
                        case 'archive':
                          widget.connection.packetManager
                              .sendChannelDelete(
                              channelId: channel.id);
                          break;
                        case 'edit':
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ChannelListRoomDialog(
                                  onSubmitted: (title,
                                      description, isPrivate) {
                                    widget.connection.packetManager
                                        .sendChannelUpdate(
                                        channelId:
                                        channel.id,
                                        name: title,
                                        description:
                                        description);
                                  },
                                  inputName: channel.name,
                                  inputDescription:
                                  channel.description ?? '',
                                  isEdit: true);
                            },
                          );
                          break;
                        case "leave":
                          widget.connection.packetManager
                              .sendChannelRemoveUser(
                            channelId: channel.id,
                            userId: widget.connection.user.id,
                          )
                              .then((value) {
                            if (value.error != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(value.error!.message),
                                duration:
                                const Duration(seconds: 10),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Odešel jste z místnosti'),
                                duration: Duration(seconds: 10),
                              ));
                              ChannelListSelectedChannel.of(
                                  context,
                                  listen: false)
                                  .setChannel(widget.connection.server, null);
                            }
                          });
                          break;
                        default:
                          break;
                      }
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),

        // Spacer between the two lists
        // const SizedBox(height: 8.0),
        // Expanded(
        //     child: SidebarBox(
        //         child: PrivateRoomList(
        //           controller: _selectedRoomController,
        //           rooms: List<RoomInfo>.generate(
        //               100000,
        //                   (index) => RoomInfo(index.toString(), 'Channel $index')
        //           ),
        //         )
        //     )
        // ),
      ],
    );
  }
}

