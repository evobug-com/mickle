import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mickle/components/permission_list/permissions.g.dart';
import 'package:mickle/core/models/utils.dart';
import 'package:mickle/core/providers/scoped/connection_provider.dart';

class ConsoleListRolesItem extends StatelessWidget {
  const ConsoleListRolesItem({super.key});

  @override
  Widget build(BuildContext context) {

    final connectionProvider = ConnectionProvider.of(context);
    final database = connectionProvider.database;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Seznam rolí", style: TextStyle(fontSize: 20)),
        ...database.roles.items.map((role) {
          final users = role.getUsers(database: database);
          final rolePermissions = role.getPermissions(database: database);
          return Card(
            child: Column(
              children: [
                ListTile(
                  title: Text("${role.name} (${users.length})"),
                  subtitle: Text("Váha: ${role.rank}"),
                ),
                const Divider(),
                ExpansionTile(
                  title: const Text("Oprávnění"),
                  children: [
                    ...database.permissions.items.groupListsBy((permission) => permissions[permission.id]!.category).entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key, style: Theme.of(context).textTheme.bodyLarge),
                                ...entry.value.map((permission) {
                                  return CheckboxListTile(
                                    title: Text(permissions[permission.id]!.name),
                                    value: rolePermissions.contains(permission),
                                    dense: true,
                                    onChanged: (value) {
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                ExpansionTile(
                  title: const Text("Uživatelé"),
                  children: [
                    ...users.map((user) {
                      return ListTile(
                        title: Text(user.displayName!),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                          },
                        ),
                      );
                    }),
                  ],
                )
              ],
            ),
          );
        }),
      ],
    );
  }
}