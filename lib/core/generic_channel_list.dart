
import 'package:flutter/material.dart';

import 'disposable.dart';
import 'notifiers/selected_channel_controller.dart';

class GenericRoomList extends StatefulWidget {
  final int itemCount;
  final String Function(int index) titleBuilder;
  final SelectedChannelController controller;
  final void Function(int index) onRoomSelected;
  final String Function(int index) getRoomUid;

  const GenericRoomList({
    super.key,
    required this.itemCount,
    required this.titleBuilder,
    required this.controller,
    required this.onRoomSelected,
    required this.getRoomUid,
  });

  @override
  GenericChannelListState createState() => GenericChannelListState();
}

class GenericChannelListState extends State<GenericRoomList> {
  final Map<String, Function> _setStates = {};

  @override
  void initState() {

    widget.controller.addListener(() {
      if (widget.controller.previousChannel != null && _setStates.containsKey(widget.controller.previousChannel!.id)) {
        _setStates[widget.controller.previousChannel!.id]!(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (BuildContext context, int index) {
        final roomId = widget.getRoomUid(index);

        return Disposable(
          onDispose: () {
            _setStates.remove(roomId);
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              _setStates[roomId] = setState;

              return ListTile(
                title: Text(widget.titleBuilder(index)),
                leading: Icon(Icons.tag),
                selected: roomId == widget.controller.currentChannel?.id,
                // Show badge in trailing
                // trailing: roomId == widget.controller.selectedRoomId
                //     ? const CircleAvatar(
                //         backgroundColor: Colors.red,
                //         radius: 4,
                //       )
                //     : null,
                onTap: () {
                  setState(() {
                    widget.onRoomSelected(index);
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}