import 'package:flutter/material.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/notifiers/current_connection.dart';

import '../core/generic_channel_list.dart';
import '../core/models/models.dart';
import '../core/notifiers/selected_channel_controller.dart';
import '../core/processor/request_processor.dart';

class EditRoomDialog extends StatefulWidget {

  final void Function(String title, String description) onSubmitted;
  final String confirmLabel;
  final String initialName;
  final String initialDescription;
  final String title;

  const EditRoomDialog({super.key, required this.onSubmitted, required this.confirmLabel, this.initialName = '', this.initialDescription = '', required this.title});

  @override
  State<StatefulWidget> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {
  final TextEditingController _createChannelNameController =
      TextEditingController();
  final TextEditingController _createChannelDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _createChannelNameController.text = widget.initialName;
    _createChannelDescriptionController.text = widget.initialDescription;
  }

  @override
  void dispose() {
    _createChannelNameController.dispose();
    _createChannelDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              labelText: 'Název',
            ),
            controller: _createChannelNameController,
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Popis',
            ),
            controller: _createChannelDescriptionController,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zrušit'),
        ),
        TextButton(
          onPressed: () {
            // Create a new channel
            widget.onSubmitted(
              _createChannelNameController.text,
              _createChannelDescriptionController.text,
            );

            Navigator.of(context).pop();
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class ChannelList extends StatelessWidget {
  final SelectedChannelController controller;
  final List<Channel> channels;

  const ChannelList(
      {super.key, required this.controller, required this.channels});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GenericRoomList(
            itemCount: channels.length,
            titleBuilder: (index) => channels[index].name ?? '<Unnamed Room>',
            controller: controller,
            onRoomSelected: (index) {
              controller.currentChannel = channels[index];
            },
            getRoomUid: (index) => channels[index].id,
            contextMenuHandler: (roomId, action) {
              switch (action) {
                case 'archive':
                  packetChannelDelete(channelId: roomId);
                  break;
                case 'edit':
                  showDialog(
                    context: context,
                    builder: (context) {
                      final channel = Database(CurrentSession().server!.id).channels.get("Channel:$roomId")!;
                      return EditRoomDialog(
                        onSubmitted: (title, description) {
                          packetChannelUpdate(channelId: roomId, name: title, description: description);
                        },
                        confirmLabel: 'Uložit',
                        title: "Editace místnosti ${channels.firstWhere((element) => element.id == roomId).name}",
                        initialName: channel.name,
                        initialDescription: channel.description ?? '',
                      );
                    },
                  );
                  break;
                default:
                  break;
              }
            }
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // Show dialog to create a new channel
            showDialog(
              context: context,
              builder: (context) {
                return EditRoomDialog(
                  onSubmitted: (title, description) {
                    packetChannelCreate(name: title, description: description);
                  },
                  confirmLabel: 'Vytvořit',
                  title: 'Vytvoření nové místnosti',
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class PrivateChannelList extends StatelessWidget {
  final SelectedChannelController controller;
  final List<Channel> channels;

  const PrivateChannelList(
      {super.key, required this.controller, required this.channels});

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
      contextMenuHandler: (roomId, action) {},
    );
  }
}
