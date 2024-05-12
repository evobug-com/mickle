// This is the main content of the app. It will do layout (sidebar, content placement)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/components/text_room/widgets/text_room_widget.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/surfaces.dart';
import 'package:talk/ui/user_avatar.dart';

import '../core/models/models.dart';
import '../core/notifiers/selected_channel_controller.dart';
import '../core/database.dart';
import '../core/notifiers/theme_controller.dart';
import '../main.dart';
import '../ui/channel_list.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SelectedChannelController _selectedChannelController = SelectedChannelController();
  final TextEditingController _createChannelNameController = TextEditingController();
  final TextEditingController _createChannelDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _selectedChannelController.dispose();
    _createChannelNameController.dispose();
    _createChannelDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = CurrentSession();
    final database = Database(session.connection!.serverId!);

    return MyScaffold(body: ListenableBuilder(listenable: session.connection!, builder: (context, value) {
      if(session.server == null || session.user == null) {
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
      // Left sidebar, content, right sidebar
      return Row(
        key: const ValueKey("Row-Sidebar-Chat-Sidebar"),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Sidebar(
              // Left sidebar will have top and bottom parts
              // Top is channel list and bottom is private channel list
              // They will be equally divided
              // Add border and padding around the lists
              child: Column(
                key: const ValueKey("Column-SidebarChannels"),
                children: <Widget>[
                  Expanded(
                    child: SidebarBox(
                      child: StreamBuilder(
                        stream: database.channels.stream,
                        initialData: database.channels.items,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final rooms = database.channels.items;
                            return ChannelList(
                              controller: _selectedChannelController,
                              channels: rooms,
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
          ListenableBuilder(
            listenable: _selectedChannelController,
            builder: (context, _) {
              return Expanded(
                child: _selectedChannelController.currentChannel != null ? TextRoomWidget(
                  channel: _selectedChannelController.currentChannel!,
                  connection: session.connection!
                ) : const Center(
                  child: Text('No channel selected'),
                )
              );
            }
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
                        listenable: session.user!,
                        builder: (context, child) {
                          return Row(
                            children: <Widget>[
                              UserAvatar(presence: UserPresence.fromString(session.user?.presence), imageUrl: session.user?.avatar,),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Bold text
                                    Text(session.user!.displayName ?? "<No name>", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if(session.user!.status != null) ...[
                                      Text(session.user!.status!),
                                    ],
                                  ],

                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.go("/settings");
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
