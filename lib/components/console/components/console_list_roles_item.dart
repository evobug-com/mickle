import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:talk/core/models/models.dart';
import '../../../core/database.dart';
import '../../../core/notifiers/current_client_provider.dart';

class ConsoleListRolesItem extends StatelessWidget {
  const ConsoleListRolesItem({super.key});

  @override
  Widget build(BuildContext context) {

    final clientProvider = CurrentClientProvider.of(context);
    final database = clientProvider.database!;

    return const SizedBox();
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     const Text("Seznam rolí", style: TextStyle(fontSize: 20)),
    //     ...database.roles.items.map((role) {
    //       final users = role.getUsers();
    //       final permissions = role.getPermissions();
    //       return Card(
    //         child: Column(
    //           children: [
    //             ListTile(
    //               title: Text("${role.name} (${users.length})"),
    //               subtitle: Text("Váha: ${role.rank}"),
    //             ),
    //             const Divider(),
    //             ExpansionTile(
    //               title: const Text("Oprávnění"),
    //               children: [
    //                 ...database.permissions.items.groupListsBy((permission) => permission.category).entries.map((entry) {
    //                   return Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Container(
    //                         padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
    //                         color: Theme.of(context).colorScheme.surfaceContainer,
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Text(entry.key, style: Theme.of(context).textTheme.bodyLarge),
    //                             ...entry.value.map((permission) {
    //                               return CheckboxListTile(
    //                                 title: Text(permission.name),
    //                                 value: permissions.contains(permission),
    //                                 dense: true,
    //                                 onChanged: (value) {
    //                                 },
    //                               );
    //                             }),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   );
    //                 }),
    //               ],
    //             ),
    //             ExpansionTile(
    //               title: const Text("Uživatelé"),
    //               children: [
    //                 ...users.map((user) {
    //                   return ListTile(
    //                     title: Text(user.displayName!),
    //                     trailing: IconButton(
    //                       icon: const Icon(Icons.remove),
    //                       onPressed: () {
    //                       },
    //                     ),
    //                   );
    //                 }),
    //               ],
    //             )
    //           ],
    //         ),
    //       );
    //     }).toList(),
    //   ],
    // );
  }
}