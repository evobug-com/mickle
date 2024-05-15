import 'package:flutter/material.dart';

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