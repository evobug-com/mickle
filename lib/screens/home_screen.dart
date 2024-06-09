// This is the main content of the app. It will do layout (sidebar, content placement)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talk/components/channel_list/core/models/channel_list_selected_room.dart';
import 'package:talk/components/channel_list/widgets/channel_list_widget.dart';
import 'package:talk/components/text_room/widgets/text_room_widget.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';
import 'package:talk/core/surfaces.dart';
import 'package:talk/ui/user_avatar.dart';

import '../core/models/models.dart';
import '../core/database.dart';
import '../components/channel_list/components/channel_list_room_dialog.dart';
import '../layout/my_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _createChannelNameController = TextEditingController();
  final TextEditingController _createChannelDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _createChannelNameController.dispose();
    _createChannelDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = CurrentClientProvider.of(context);
    final client = clientProvider.selectedClient!;

    return MyScaffold(body: ListenableBuilder(listenable: client.serverData, builder: (context, value) {
      if(client.server == null || client.user == null) {
        // Show loading spinner and text that we are getting the server info
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20.0),
              Text('Loading server info...'),
            ],
          ),
        );
      }

      assert(clientProvider.database != null);
      final database = clientProvider.database!;
      final packetManager = clientProvider.packetManager!;

      // Left sidebar, content, right sidebar
      return ChangeNotifierProvider(
        create: (context) => ChannelListSelectedRoom(),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Sidebar(
                // Left sidebar will have top and bottom parts
                // Top is channel list and bottom is private channel list
                // They will be equally divided
                // Add border and padding around the lists
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SidebarBox(
                        child: StreamBuilder(
                          stream: database.channels.stream,
                          initialData: client.server!.getChannels(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ChannelListWidget(
                                  client: client,
                                  server: client.server!,
                                  contextMenuHandler: (channel, action) {
                                    switch (action) {
                                      case 'archive':
                                        packetManager.sendChannelDelete(channelId: channel.id);
                                        break;
                                      case 'edit':
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return ChannelListRoomDialog(
                                              onSubmitted: (title, description, isPrivate) {
                                                packetManager.sendChannelUpdate(channelId: channel.id, name: title, description: description);
                                              },
                                              inputName: channel.name,
                                              inputDescription: channel.description ?? '',
                                              isEdit: true
                                            );
                                          },
                                        );
                                        break;
                                      case "leave":
                                        packetManager.sendChannelRemoveUser(
                                          channelId: channel.id,
                                          userId: client.user!.id,
                                        ).then((value) {
                                          if(value.error != null) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(value.error!),
                                              duration: const Duration(seconds: 10),
                                            ));
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text('Odešel jste z místnosti'),
                                              duration: Duration(seconds: 10),
                                            ));
                                            ChannelListSelectedRoom.of(context, listen: false).selectedChannel = null;
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
                ),
              ),
            ),
            Consumer<ChannelListSelectedRoom>(
              builder: (context, value, _) {
                return Expanded(
                    child: value.selectedChannel != null ? TextRoomWidget(
                      channel: value.selectedChannel!,
                      client: client,
                    ) : const Center(
                      child: Text('No channel selected'),
                    )
                );
              },
            ),
            // If an
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Sidebar(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Create a box with a border and padding to hold the current user info
                    SidebarBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListenableBuilder(
                          listenable: clientProvider.user!,
                          builder: (context, child) {
                            return Row(
                              children: <Widget>[
                                UserAvatar(presence: UserPresence.fromString(clientProvider.user!.presence), imageUrl: clientProvider.user!.avatar,),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Bold text
                                      Text(clientProvider.user!.displayName ?? "<No name>", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      if(clientProvider.user!.status != null) ...[
                                        Text(clientProvider.user!.status!),
                                      ],
                                    ],

                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.goNamed("settings",
                                      queryParameters: {"tab": "general"},
                                    );
                                  },
                                  icon: const Icon(Icons.settings),
                                )
                              ],

                            );
                          }
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: SidebarBox(
                        child: Column(
                          children: <Widget>[
                            const Text('Users'),
                            const SizedBox(height: 8.0),
                            Expanded(
                              child: StreamBuilder(
                                  stream: database.users.stream,
                                  initialData: database.users.items,
                                  builder: (context, snapshot) {

                                    if(!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    List<User> users = database.users.items;

                                    return ListView.builder(
                                      itemCount: users.length,
                                      itemBuilder: (context, index) {
                                        return ListenableBuilder(
                                          listenable: users[index],
                                          builder: (context, widget) {
                                            return ListTile(
                                              // contentPadding: EdgeInsets.fromLTRB(4,0,4,0),
                                              // Avatar leading
                                              leading: UserAvatar(presence: UserPresence.fromString(users[index].presence), imageUrl: users[index].avatar,),
                                              // User with status
                                              title: Text(users[index].displayName ?? "<No name>"),
                                              subtitle: users[index].status != null ? Text(users[index].status!) : null,
                                              // trailing message icon
                                              trailing: const IconButton(
                                                icon: Icon(Icons.message),
                                                onPressed: null,
                                              ),
                                              onTap: () {
                                                // Cycle all enum status
                                                // final UserPresence newStatus = UserPresence.values[(users[index].presence.index + 1) % UserPresence.values.length];
                                                // users[index].presence = newStatus;
                                                // Database().store.box<User>().put(users[index]);
                                              },

                                            );
                                          }
                                        );
                                      },
                                    );
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }));
  }
}

class SidebarBox extends StatelessWidget {
  final Widget child;

  const SidebarBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Material: https://github.com/flutter/flutter/issues/73315
    return Material(
      child: Surface.surfaceContainer(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: child
      )
    );
  }
}

class Sidebar extends StatefulWidget {
  final Widget child;

  const Sidebar({super.key, required this.child});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: widget.child,
    );
  }
}
