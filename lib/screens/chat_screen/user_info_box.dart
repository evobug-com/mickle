import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';
import 'package:talk/ui/user_avatar.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';
import 'package:talk/core/completer.dart';
import 'package:provider/provider.dart';

import 'sidebar_box.dart';

enum AvatarUploadMethod { url, localFile }

class UserInfoBox extends StatefulWidget {
  final ConnectionProvider connection;

  const UserInfoBox({super.key, required this.connection});

  @override
  _UserInfoBoxState createState() => _UserInfoBoxState();
}

class _UserInfoBoxState extends State<UserInfoBox> {
  late TextEditingController _statusController;
  late TextEditingController _avatarUrlController;
  String? _newPresence;
  bool _isLoading = false;
  String? _errorMessage;
  AvatarUploadMethod _avatarUploadMethod = AvatarUploadMethod.url;

  @override
  void initState() {
    super.initState();
    _statusController = TextEditingController(text: widget.connection.user.status);
    _avatarUrlController = TextEditingController(text: widget.connection.user.avatar);
    _newPresence = widget.connection.user.presence;
  }

  @override
  void dispose() {
    _statusController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SidebarBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListenableBuilder(
          listenable: widget.connection.user,
          builder: (context, child) {
            return GestureDetector(
              onTap: () => _showEditPopup(context),
              child: Row(
                children: <Widget>[
                  UserAvatar(
                    presence: UserPresence.fromString(widget.connection.user.presence),
                    imageUrl: widget.connection.user.avatar,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.connection.user.displayName ?? "<No name>",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (widget.connection.user.status != null) ...[
                          Text(widget.connection.user.status!),
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
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditPopup(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clientProvider = Provider.of<CurrentClientProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              title: Text('Edit Profile', style: TextStyle(color: colorScheme.onSurface)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    _buildStatusField(colorScheme),
                    const SizedBox(height: 16),
                    _buildPresenceDropdown(colorScheme),
                    const SizedBox(height: 16),
                    _buildAvatarUploadOptions(colorScheme, setState),
                    if (_isLoading)
                      CircularProgressIndicator(color: colorScheme.primary)
                    else if (_errorMessage != null)
                      Text(_errorMessage!, style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Apply', style: TextStyle(color: colorScheme.primary)),
                  onPressed: _isLoading ? null : () => _applyChanges(context, clientProvider),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusField(ColorScheme colorScheme) {
    return TextField(
      controller: _statusController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildPresenceDropdown(ColorScheme colorScheme) {
    return DropdownButtonFormField<String>(
      value: _newPresence,
      dropdownColor: colorScheme.surface,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Presence',
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      items: ['online', 'offline', 'away', 'busy', 'invisible']
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: colorScheme.onSurface)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => _newPresence = newValue);
      },
    );
  }

  Widget _buildAvatarUploadOptions(ColorScheme colorScheme, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avatar Upload Method', style: TextStyle(color: colorScheme.onSurface)),
        Row(
          children: [
            Radio<AvatarUploadMethod>(
              value: AvatarUploadMethod.url,
              groupValue: _avatarUploadMethod,
              onChanged: (AvatarUploadMethod? value) {
                setState(() {
                  _avatarUploadMethod = value!;
                });
              },
            ),
            Text('URL', style: TextStyle(color: colorScheme.onSurface)),
            Radio<AvatarUploadMethod>(
              value: AvatarUploadMethod.localFile,
              groupValue: _avatarUploadMethod,
              onChanged: null, // Disabled
            ),
            Text('Local File (Disabled)',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))
            ),
          ],
        ),
        if (_avatarUploadMethod == AvatarUploadMethod.url)
          TextField(
            controller: _avatarUrlController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Avatar URL',
              hintText: 'Enter the URL of your avatar image',
              labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
        if (_avatarUploadMethod == AvatarUploadMethod.localFile)
          Text('Local file upload is currently disabled',
              style: TextStyle(color: colorScheme.error)
          ),
      ],
    );
  }

  void _applyChanges(BuildContext context, CurrentClientProvider clientProvider) async {
    final packetManager = clientProvider.packetManager!;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_statusController.text != widget.connection.user.status) {
        await packetManager.sendUserChangeStatus(status: _statusController.text).wrapInCompleter().future;
      }
      if (_newPresence != widget.connection.user.presence) {
        await packetManager.sendUserChangePresence(presence: _newPresence!).wrapInCompleter().future;
      }
      if (_avatarUploadMethod == AvatarUploadMethod.url &&
          _avatarUrlController.text != widget.connection.user.avatar) {
        await packetManager.sendUserChangeAvatar(avatar: _avatarUrlController.text).wrapInCompleter().future;
      }

      Navigator.of(context).pop(); // Close the dialog on success
    } catch (e) {
      setState(() {
        _errorMessage = "Error updating profile: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}