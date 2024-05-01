// User avatar has a badge for states: Online, Away, Do not disturb, Offline
import 'package:flutter/material.dart';

import '../core/database.dart';

Color _getColor(UserPresence status) {
  switch (status) {
    case UserPresence.online:
      return Colors.green;
    case UserPresence.away:
      return Colors.yellow;
    case UserPresence.busy:
      return Colors.red;
    case UserPresence.offline:
      return Colors.grey;
  }
  return Colors.grey;
}


class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final UserPresence presence;
  
  const UserAvatar({super.key, this.imageUrl, required this.presence});


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,

        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: _getColor(presence),
              shape: BoxShape.circle,
            )
          )
        )
      ]
    );
  }
}
