// This is the main content of the app. It will do layout (sidebar, content placement)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/ui/user_avatar.dart';
import 'package:talk/core/network/request.dart' as request;
import 'package:talk/core/models/models.dart' as models;

import '../core/models/models.dart';
import '../core/notifiers/selected_room_controller.dart';
import '../core/database.dart';
import '../core/notifiers/theme_controller.dart';
import '../core/theme.dart';
import '../main.dart';
import '../ui/channel_list.dart';
import '../ui/channel_message.dart';

class CachedScrollController {
  final ScrollController controller;
  double? position;

  factory CachedScrollController() {
    final ScrollController controller = ScrollController();
    final cached = CachedScrollController._(controller, 0);
    controller.addListener(() {
      cached.position = controller.position.pixels;
    });
    return cached;
  }

  CachedScrollController._(this.controller, this.position);

  bool get hasClients => controller.hasClients;

  jumpToCached() {
    controller.jumpTo(position!);
  }

  scrollToBottom() {
    controller.jumpTo(controller.position.maxScrollExtent);
  }

  void dispose() {
    controller.dispose();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SelectedChannelController _selectedChannelController = SelectedChannelController();
  final TextEditingController _chatTextController = TextEditingController();

  final Map<String, CachedScrollController> _scrollControllers = {};
  final FocusNode _chatTextFocus = FocusNode();
  bool nextRenderScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    // Listen to the selected channel controller
    _selectedChannelController.addListener(() {
      print("Selected channel changed to ${_selectedChannelController.currentChannel?.id}");
      // Restore the scroll controller for the selected channel
      if(_scrollControllers.containsKey(_selectedChannelController.currentChannel!.id)) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollControllers[_selectedChannelController.currentChannel!.id]!.jumpToCached();
        });
      }
    });
  }

  // Returns true if the chat is scrolled to the bottom
  shouldScrollToBottom() {
    final chatScrollController = _scrollControllers[_selectedChannelController.currentChannel!.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      return chatScrollController.position == chatScrollController.controller.position.maxScrollExtent;
    }
    return true;
  }

  scrollToBottom() {
    final chatScrollController = _scrollControllers[_selectedChannelController.currentChannel!.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      chatScrollController.scrollToBottom();
    }
  }

  @override
  void dispose() {
    _selectedChannelController.dispose();
    _chatTextController.dispose();
    _chatTextFocus.dispose();
    for (var element in _scrollControllers.values) {
      element.dispose();
    }
    super.dispose();
  }

  getMessagesForChannel(String channelId) {
    final database = Database(CurrentSession().connection!.serverId!);
    return database.messages.items.where((message) => database.channelMessages.output(message.id) == channelId).toList(growable: false);
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
                          initialData: database.channels.items,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final rooms = snapshot.data as List<Channel>;
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
                      )),
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
              builder: (context, child) {

                print("Rebuilding chat screen with channel ${_selectedChannelController.currentChannel?.id}");

                if(_selectedChannelController.currentChannel == null) {
                  return const Expanded(
                    child: Center(
                      child: Text('Select a channel to start chatting'),
                    ),
                  );
                }

                return Expanded(
                  // At bottom of the screen we need resizable text input
                  // At top there will be scrollable chat history
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          ChannelHeader(channel: _selectedChannelController.currentChannel!),
                          Expanded(
                            child: StreamBuilder(
                              key: ValueKey(_selectedChannelController.currentChannel!.id),
                              stream: database.messages.stream.where((message) => database.channelMessages.output(message.id) == _selectedChannelController.currentChannel!.id),
                              initialData: getMessagesForChannel(_selectedChannelController.currentChannel!.id),
                              builder: (context, snapshot) {
                                final messages = getMessagesForChannel(_selectedChannelController.currentChannel!.id);

                                if (snapshot.hasData) {

                                  // If we are at bottom, scroll to bottom on new message
                                  nextRenderScrollToBottom = shouldScrollToBottom();

                                  // Post frame callback to scroll to bottom
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if(nextRenderScrollToBottom) {
                                      scrollToBottom();
                                      nextRenderScrollToBottom = false;
                                    }
                                  });

                                  return ListView.builder(
                                    controller: _scrollControllers.putIfAbsent(_selectedChannelController.currentChannel!.id, () => CachedScrollController()).controller,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final message = messages[index];
                                      final user = database.users.get("User:${message.user}");

                                      return ChannelMessage(
                                        message: message,
                                        user: user,
                                        onEdit: null,
                                        onDelete: null,
                                      );
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
                          const Divider(height: 1),
                          TextField(
                            controller: _chatTextController,
                            focusNode: _chatTextFocus,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Message #${
                                _selectedChannelController.currentChannel?.name
                              }',
                            ),
                            onSubmitted: (value) {
                              if(value.isEmpty) {
                                return;
                              }

                              session.connection!.send(
                                request.Message(
                                  channelId: _selectedChannelController.currentChannel!.id!,
                                  message: value,
                                ).serialize(),
                              );

                              nextRenderScrollToBottom = true;

                              // Clean the input for next message
                              _chatTextController.clear();

                              // Keep the chat input focused after sending message
                              _chatTextFocus.requestFocus();
                            },
                          ),
                        ],
                      ),
                    ));
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

                                  List<User> users = snapshot.data as List<User>;

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

class ChannelHeader extends StatefulWidget {
  final Channel channel;

  const ChannelHeader({super.key, required this.channel});

  @override
  State<ChannelHeader> createState() => _ChannelHeaderState();
}

class _ChannelHeaderState extends State<ChannelHeader> {
  bool _isHovering = false;


  @override
  Widget build(BuildContext context) {
    // First line: Title with badge of how many pinned messages is there
    // Second line: Description of the current room
    // On hover, it will show Row with pinned messages

    return SidebarBox(
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            _isHovering = true;
          });
        },
        onExit: (event) {
          setState(() {
            _isHovering = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.channel.name ?? "<No name>",
                  ),
                  // Colored Box with icon on left, number on right
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(4, 1, 4, 1),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.push_pin, size: 11.0),
                          SizedBox(width: 4.0),
                          Text('5'),
                        ]
                      )
                    )
                  )
                ]
              
              ),
              Text(
                widget.channel.description ?? "<No description>",
                style: ThemeController.theme(context).textTheme.bodySmall,
                      
              ),
              // const Divider(height: 1),
              // Row with pinned messages
              if(_isHovering) ...[
                const Divider(height: 1),
                const Row(
                  children: [
                    
                  ]

                )


              ]

            ]
          
          
          ),
        ),
      )


    );

  }
}


class SidebarBox extends StatelessWidget {
  final Widget child;

  const SidebarBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Material: https://github.com/flutter/flutter/issues/73315
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: ThemeController.scheme(context).surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
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
