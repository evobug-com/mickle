import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';
import 'package:talk/ui/user_avatar.dart';

import 'sidebar_box.dart';

class UserInfoBox extends StatelessWidget {
  final ConnectionProvider connection;

  const UserInfoBox({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    return  // Create a box with a border and padding to hold the current user info
      SidebarBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListenableBuilder(
              listenable: connection.user,
              builder: (context, child) {
                return Row(
                  children: <Widget>[
                    UserAvatar(
                      presence: UserPresence.fromString(
                          connection.user.presence),
                      imageUrl: connection.user.avatar,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          // Bold text
                          Text(
                              connection.user.displayName ??
                                  "<No name>",
                              style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold)),
                          if (connection.user.status !=
                              null) ...[
                            Text(connection.user.status!),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.goNamed(
                          "settings",
                          queryParameters: {"tab": "general"},
                        );
                      },
                      icon: const Icon(Icons.settings),
                    )
                  ],
                );
              }),
        ),
      );
  }
}