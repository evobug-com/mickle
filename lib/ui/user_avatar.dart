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
  final UserPresence? presence;
  
  const UserAvatar({super.key, this.imageUrl, this.presence});


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: imageUrl != null ? FadeInImage.assetNetwork(
            placeholder: 'assets/images/default_avatar.png',
            image: imageUrl!,
            imageErrorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return const Image(
                image: AssetImage('assets/images/default_avatar.png'),
              );
            },
          ).image : const AssetImage('assets/images/default_avatar.png'),
          backgroundColor: Colors.transparent,

        ),
        if (presence != null)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getColor(presence!),
              shape: BoxShape.circle,
            )
          )
        )
      ]
    );
  }
}
