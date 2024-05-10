import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'package:flutter/foundation.dart';
import 'package:talk/core/notifiers/current_connection.dart';

import '../database.dart';
part 'models.g.dart';

extension UserExtension on User {
  List<Role> getRoles() {
    CurrentSession session = CurrentSession();
    Database database = Database(session.server!.id);
    final roles = database.roleUsers.whereOutput(id);
    return roles.map((role) => database.roles.get("Role:$role")!).toList();
  }
}

extension RoleExtension on Role {
  List<Permission> getPermissions() {
    CurrentSession session = CurrentSession();
    Database database = Database(session.server!.id);
    final permissions = database.rolePermissions.whereInput(id);
    return permissions.map((permissionId) => database.permissions.get("Permission:$permissionId")!).toList();
  }
}