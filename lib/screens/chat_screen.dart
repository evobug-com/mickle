// This is the main content of the app. It will do layout (sidebar, content placement)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/areas/connection/connection_status.dart';
import 'package:talk/components/channel_list/core/models/channel_list_selected_room.dart';
import 'package:talk/components/text_room/widgets/text_room_widget.dart';
import 'package:talk/components/voice_room/components/voice_room_control_panel.dart';
import 'package:talk/components/voice_room/core/models/voice_room_current.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';

import '../core/providers/global/selected_server_provider.dart';
import '../layout/my_scaffold.dart';
import 'chat_screen/channel_list_container.dart';
import 'chat_screen/sidebar.dart';
import 'chat_screen/user_info_box.dart';
import 'chat_screen/user_list_container.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  Widget _buildLeftSidebar(BuildContext context, ConnectionProvider connection) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: Sidebar(
        child: ChannelListContainer(connection: connection),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ConnectionProvider connection) {
    return Expanded(
      child: Consumer<ChannelListSelectedChannel>(
        builder: (context, value, _) {
          return value.getChannel(connection.server) != null
              ? TextRoomWidget(
            channel: value.getChannel(connection.server),
            connection: connection,
          )
              : const Center(child: Text('No channel selected'));
        },
      ),
    );
  }

  Widget _buildRightSidebar(BuildContext context, ConnectionProvider connection, VoiceRoomCurrent currentVoiceRoom) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Sidebar(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserInfoBox(connection: connection),
            _buildVoiceRoomControlPanel(currentVoiceRoom),
            const SizedBox(height: 8.0),
            Expanded(child: UserListContainer(connection: connection)),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceRoomControlPanel(VoiceRoomCurrent currentVoiceRoom) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: currentVoiceRoom.currentChannel != null
          ? const Column(
        key: ValueKey("control-panel"),
        children: [
          SizedBox(height: 8.0),
          VoiceRoomControlPanel()
        ],
      )
          : const SizedBox(key: ValueKey("control-panel-hidden")),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedServerProvider = Provider.of<SelectedServerProvider>(context);
    if (selectedServerProvider.connection == null) {
      throw Exception("No client selected");
    }

    return MyScaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedServerProvider.connection!.status,
        builder: (context, status, _) {
          if (status != ConnectionStatus.authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer2<ConnectionProvider, VoiceRoomCurrent>(
            builder: (context, connection, currentVoiceRoom, _) {
              return Row(
                children: [
                  _buildLeftSidebar(context, connection),
                  _buildMainContent(context, connection),
                  _buildRightSidebar(context, connection, currentVoiceRoom),
                ],
              );
            },
          );
        },
      ),
    );
  }
}