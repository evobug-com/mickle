import 'package:flutter/material.dart';
import 'package:talk/core/notifiers/theme_controller.dart';

class ChannelListRoomDialog extends StatefulWidget {

  final bool isEdit;
  final String inputName;
  final String inputDescription;

  final void Function(String title, String description, bool? isPrivate) onSubmitted;

  const ChannelListRoomDialog({super.key, required this.onSubmitted, this.inputName = '', this.inputDescription = '', required this.isEdit});

  @override
  State<StatefulWidget> createState() => _ChannelListRoomDialogState();
}

class _ChannelListRoomDialogState extends State<ChannelListRoomDialog> {
  final TextEditingController _createChannelNameController =
  TextEditingController();
  final TextEditingController _createChannelDescriptionController =
  TextEditingController();
  bool _isPrivateRoom = false;

  @override
  void initState() {
    super.initState();
    _createChannelNameController.text = widget.inputName;
    _createChannelDescriptionController.text = widget.inputDescription;
  }

  @override
  void dispose() {
    _createChannelNameController.dispose();
    _createChannelDescriptionController.dispose();
    super.dispose();
  }

  String get dialogLabelTitle {
    return widget.isEdit ? 'Editace místnosti' : 'Vytvoření nové místnosti';
  }

  String get confirmButtonLabel {
    return widget.isEdit ? 'Upravit' : 'Create';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.theme(context);
    return SimpleDialog(
      title: Text(dialogLabelTitle),
      contentPadding: const EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(
            labelText: 'Název',
          ),
          controller: _createChannelNameController,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Popis',
          ),
          controller: _createChannelDescriptionController,
        ),
        if(!widget.isEdit) ...[
          const SizedBox(height: 8),
          SwitchListTile(
            value: _isPrivateRoom,
            onChanged: (value) {
              setState(() {
                _isPrivateRoom = value;
              });
            },
            title: const Text('Soukromá místnost'),
            subtitle: const Text('Pokud je zaškrtnuto, místnost bude viditelná pouze pro Vás. Ostatní uživatelé musíte pozvat ručně.'),
            contentPadding: const EdgeInsets.all(0),
            hoverColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tileColor: Colors.transparent,
            splashRadius: 0.0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

          ),
        ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(child: Text(confirmButtonLabel), onPressed: () {
              widget.onSubmitted(
                  _createChannelNameController.text,
                  _createChannelDescriptionController.text,
                  _isPrivateRoom
              );
              Navigator.of(context).pop();
            }),
          ],
        )
      ],
    );
  }
}