// User avatar has a badge for states: Online, Away, Do not disturb, Offline
import 'package:flutter/material.dart';
import 'package:talk/core/images/safe_network_image_provider.dart';

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
  final double size;
  final double? presenceSize;

  const UserAvatar({super.key, this.imageUrl, this.presence, this.size = 20, this.presenceSize = 12});


  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        CircleAvatar(
          radius: size,
          backgroundImage: SafeNetworkImageProvider(imageUrl, defaultAssetPath: 'assets/images/default_avatar.png'),
          onBackgroundImageError: (exception, stackTrace) {
            print('Error loading image: $exception');
          },
          backgroundColor: Colors.transparent,

        ),
        if (presence != null)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: presenceSize,
            height: presenceSize,
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
