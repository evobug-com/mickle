import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';
import 'package:talk/screens/chat_screen/sidebar_box.dart';
import 'package:talk/ui/user_avatar.dart';

enum AvatarUploadMethod { url, localFile }

class UserInfoBox extends StatefulWidget {
  final ConnectionProvider connection;

  const UserInfoBox({super.key, required this.connection});

  @override
  _UserInfoBoxState createState() => _UserInfoBoxState();
}

class _UserInfoBoxState extends State<UserInfoBox> with SingleTickerProviderStateMixin {
  late TextEditingController _displayNameController;
  late TextEditingController _statusController;
  late TextEditingController _avatarUrlController;
  String? _newPresence;
  bool _isLoading = false;
  String? _errorMessage;
  AvatarUploadMethod _avatarUploadMethod = AvatarUploadMethod.url;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ValueNotifier<File?> _selectedFile = ValueNotifier(null);
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.connection.user.displayName);
    _statusController = TextEditingController(text: widget.connection.user.status);
    _avatarUrlController = TextEditingController(text: widget.connection.user.avatarUrl);
    _newPresence = widget.connection.user.presence;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _statusController.dispose();
    _avatarUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SidebarBox(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListenableBuilder(
          listenable: widget.connection.user,
          builder: (context, child) {
            return GestureDetector(
              onTap: () => _showEditPopup(context),
              child: Row(
                children: <Widget>[
                  UserAvatar(
                    presence: UserPresence.fromString(widget.connection.user.presence),
                    imageUrl: widget.connection.user.avatarUrl,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.connection.user.displayName ?? "<No name>",
                          style: theme.textTheme.titleMedium,
                        ),
                        if (widget.connection.user.status != null) ...[
                          Text(widget.connection.user.status!, style: theme.textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.pushNamed(
                        "settings",
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + 0.2 * _animation.value,
                  child: Opacity(
                    opacity: _animation.value,
                    child: Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        width: 400,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAvatarSection(colorScheme, setState),
                              const SizedBox(height: 24),
                              _buildInfoField('Display Name', _buildDisplayNameField(colorScheme)),
                              const SizedBox(height: 16),
                              _buildInfoField('Status', _buildStatusField(colorScheme)),
                              const SizedBox(height: 16),
                              _buildInfoField('Presence', _buildPresenceDropdown(colorScheme, setState)),
                              const SizedBox(height: 24),
                              if (_isLoading)
                                Center(child: CircularProgressIndicator(color: colorScheme.primary))
                              else if (_errorMessage != null)
                                Text(_errorMessage!, style: TextStyle(color: colorScheme.error)),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildAnimatedButton('Cancel', colorScheme, () => Navigator.of(context).pop()),
                                  const SizedBox(width: 16),
                                  _buildAnimatedButton('Apply', colorScheme, _isLoading ? null : () => _applyChanges(context, widget.connection)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
    _animationController.forward();
  }

  Widget _buildAvatarSection(ColorScheme colorScheme, StateSetter setState) {
    return Center(
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _selectedFile,
            builder: (BuildContext context, File? value, Widget? child) {
              return UserAvatar(
                presence: null,
                imageUrl: _getAvatarImageUrl(),
                size: 50,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('URL', style: TextStyle(color: colorScheme.onSurface)),
              Switch(
                value: _avatarUploadMethod == AvatarUploadMethod.url,
                onChanged: (value) {
                  setState(() {
                    _avatarUploadMethod = value ? AvatarUploadMethod.url : AvatarUploadMethod.localFile;
                  });
                },
                activeColor: colorScheme.primary,
              ),
              Text('Local File', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
          if (_avatarUploadMethod == AvatarUploadMethod.url) ...[
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _avatarUrlController,
              hint: 'Enter avatar URL',
              colorScheme: colorScheme,
            ),
          ] else ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(_selectedFileName ?? 'Select File'),
            ),
          ],
        ],
      ),
    );
  }

  String _getAvatarImageUrl() {
    if (_avatarUploadMethod == AvatarUploadMethod.url) {
      print("Avatar URL: ${_avatarUrlController.text}");
      return _avatarUrlController.text;
    } else if (_selectedFile.value != null) {
      print("Avatar File: ${_selectedFile.value!.path}");
      return _selectedFile.value!.path;
    } else {
      print("Avatar Image: ${widget.connection.user.avatarUrl}");
      return widget.connection.user.avatarUrl ?? '';
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        print(result.files.single.path);
        _selectedFile.value = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Widget _buildInfoField(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required ColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDisplayNameField(ColorScheme colorScheme) {
    return _buildCustomTextField(
      controller: _displayNameController,
      hint: 'Enter display name',
      colorScheme: colorScheme,
    );
  }

  Widget _buildStatusField(ColorScheme colorScheme) {
    return _buildCustomTextField(
      controller: _statusController,
      hint: 'Enter status',
      colorScheme: colorScheme,
    );
  }

  Widget _buildPresenceDropdown(ColorScheme colorScheme, StateSetter setState) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _newPresence,
          dropdownColor: colorScheme.surface,
          style: TextStyle(color: colorScheme.onSurface),
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() => _newPresence = newValue);
          },
          items: ['online', 'offline', 'away', 'busy', 'invisible']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _getPresenceColor(value, colorScheme),
                  ),
                  const SizedBox(width: 8),
                  Text(value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getPresenceColor(String presence, ColorScheme colorScheme) {
    switch (presence) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'busy':
        return Colors.red;
      case 'invisible':
        return Colors.grey;
      default:
        return colorScheme.onSurface;
    }
  }

  Widget _buildAnimatedButton(String text, ColorScheme colorScheme, VoidCallback? onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: text == 'Apply' ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                text,
                style: TextStyle(
                  color: text == 'Apply' ? colorScheme.onPrimary : colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applyChanges(BuildContext context, ConnectionProvider connection) async {
    final packetManager = connection.packetManager;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_displayNameController.text.isEmpty) {
        _errorMessage = "Display name cannot be empty";
        return;
      }

      if (_displayNameController.text != widget.connection.user.displayName) {
        final result = await packetManager.sendSetUserDisplayName(displayName: _displayNameController.text);
        if (result.error != null) {
          _errorMessage = result.error?.message;
          return;
        }

        // Update the display name in the local database
        final db = connection.database;
        final user = db.users.firstWhere((user) => user.id == connection.user.id)
          ..displayName = _displayNameController.text;
        user.notify();
      }

      final status = _statusController.text.isEmpty ? null : _statusController.text;
      if (status != widget.connection.user.status) {
        final result = await packetManager.sendSetUserStatus(status: status);
        if (result.error != null) {
          _errorMessage = result.error?.message;
          return;
        }

        // Update the status in the local database
        final db = connection.database;
        final user = db.users.firstWhere((user) => user.id == connection.user.id)
          ..status = status;
        user.notify();
      }
      if (_newPresence != widget.connection.user.presence) {
        final result = await packetManager.sendSetUserPresence(presence: _newPresence!);
        if (result.error != null) {
          _errorMessage = result.error?.message;
          return;
        }

        // Update the presence in the local database
        final db = connection.database;
        final user = db.users.firstWhere((user) => user.id == connection.user.id)
          ..presence = _newPresence!;
        user.notify();
      }

      if (_avatarUploadMethod == AvatarUploadMethod.url) {
        final avatar = _avatarUrlController.text.isEmpty ? null : _avatarUrlController.text;
        if (avatar != widget.connection.user.avatarUrl) {
          final result = await packetManager.sendSetUserAvatar(avatar: avatar);
          if (result.error != null) {
            _errorMessage = result.error?.message;
            return;
          }

          // Update the avatar in the local database
          final db = connection.database;
          final user = db.users.firstWhere((user) => user.id == connection.user.id)
            ..avatar = avatar;
          user.notify();
        }
      } else if (_selectedFile.value != null) {
        final avatarBlob = base64Encode(await _selectedFile.value!.readAsBytes());
        final result = await packetManager.sendSetUserAvatar(avatarBlob: avatarBlob);
        if (result.error != null) {
          _errorMessage = result.error?.message;
          return;
        }

        // Update the avatar in the local database
        // Note: You might want to update this once you receive the processed avatar URL from the server
        final db = connection.database;
        final user = db.users.firstWhere((user) => user.id == connection.user.id)
          ..avatar = null; // Temporary, until you receive the new avatar URL
        user.notify();
      }

      await _animationController.reverse();
      Navigator.of(context).pop();
    } catch (e) {
      _errorMessage = "Unable to update profile. Please try again.";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}