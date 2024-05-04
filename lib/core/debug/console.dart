// Console is a overlay that can be used to display messages, errors, and warnings.
// It can be used to control the audio volume, etc...

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/network/utils.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/storage/storage.dart';
import 'package:talk/core/network/request.dart' as request;

import '../notifiers/theme_controller.dart';

class Console extends StatefulWidget {
  const Console({super.key});

  @override
  State<StatefulWidget> createState() => ConsoleState();
}

class ErrorItem {
  final String title;
  final String message;

  ErrorItem(this.title, this.message);
}

class ConsoleState extends State<Console> {
  bool _isVisible = false;
  List<ErrorItem> _errors = [];

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final TextEditingController _newDisplayNameController = TextEditingController();
  final TextEditingController _newStatusController = TextEditingController();
  final TextEditingController _newAvatarController = TextEditingController();


  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyboardToggleConsole);
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _errors.add(ErrorItem(details.exceptionAsString(), details.stack.toString()));
      AudioManager.playSingleShot("Master", AssetSource("audio/error.wav"));
      if(originalOnError != null) {
        originalOnError(details);
      }
    };
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardToggleConsole);
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newDisplayNameController.dispose();
    _newStatusController.dispose();
    _newAvatarController.dispose();
    super.dispose();
  }

  bool _keyboardToggleConsole(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.f12 && event is KeyDownEvent) {
      setState(() {
        _isVisible = !_isVisible;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: _isVisible ? _buildConsole() : const SizedBox.shrink(),
    );
  }

  Widget buildGeneralTab() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General tab with general information
          Expanded(
            child: ListView(
              children: [
                // Change password
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text("Change Password"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Change Password"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "Old Password",
                                  ),
                                  obscureText: true,
                                  controller: _oldPasswordController,
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "New Password",
                                  ),
                                  obscureText: true,
                                  controller: _newPasswordController,
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "Confirm New Password",
                                  ),
                                  obscureText: true,
                                  controller: _confirmPasswordController,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {

                                  // Check if password is not empty, show toast if it is
                                  if(_newPasswordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password cannot be empty")));
                                    return;
                                  }

                                  // Check if password is valid, show toast if not
                                  if(_newPasswordController.text != _confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
                                    return;
                                  }

                                  CurrentSession().connection!.send(request.ChangePassword(
                                    requestId: getNewRequestId(),
                                    oldPassword: _oldPasswordController.text,
                                    newPassword: _newPasswordController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: Text("Change"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Change display name
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Change Display Name"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Change Display Name"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "New Display Name",
                                  ),
                                  controller: _newDisplayNameController,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {

                                  // Check if display name is not empty, show toast if it is
                                  if(_newDisplayNameController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Display name cannot be empty")));
                                    return;
                                  }

                                  CurrentSession().connection!.send(request.ChangeDisplayName(
                                    requestId: getNewRequestId(),
                                    displayName: _newDisplayNameController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: Text("Change"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Change status
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text("Change Status"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Change Status"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "New Status",
                                  ),
                                  controller: _newStatusController,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {

                                  CurrentSession().connection!.send(request.ChangeStatus(
                                    requestId: getNewRequestId(),
                                    status: _newStatusController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: Text("Change"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Change avatar
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text("Change Avatar"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Change Avatar"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "New Avatar URL",
                                  ),
                                  controller: _newAvatarController,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {

                                  CurrentSession().connection!.send(request.ChangeAvatar(
                                    requestId: getNewRequestId(),
                                    avatar: _newAvatarController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: Text("Change"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Change presence (pick from online, away, do not disturb, etc...)
                ListTile(
                  leading: Icon(Icons.circle),
                  title: Text("Change Presence"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Change Presence"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListenableBuilder(
                                  listenable: CurrentSession().connection!.user!,
                                  builder: (context, child) {
                                    return DropdownButton<String>(
                                      value: CurrentSession().connection!.user!.presence!,
                                      items: ["online", "offline", "away", "busy", "invisible"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      onChanged: (value) {
                                        // Change presence
                                        CurrentSession().connection!.send(request.ChangePresence(
                                          requestId: getNewRequestId(),
                                          presence: value!,
                                        ).serialize());
                                      },
                                    );
                                  }
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Change"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
              ],
            ),
          ),
        ]
    );
  }

  Widget _buildConsole() {
    AudioManager audioManager = AudioManager();
    final scheme = ThemeController.scheme(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withOpacity(0.99)),

      // Tabs with different sections, like Audio, Network, etc...
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Console", style: TextStyle(fontSize: 20)),
              Text("Select a tab to view more information",
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          Divider(),
          // Audio section
          DefaultTabController(
            length: 5,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    // The tab is at the top of the screen
                    tabs: [
                      Tab(text: "General"),
                      Tab(text: "Errors"),
                      Tab(text: "Audio"),
                      Tab(text: "Network"),
                      Tab(text: "Settings"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                        children: [
                          buildGeneralTab(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Error tab with error messages, warnings, etc...
                              Expanded(
                                child: ListView(
                                  children: _errors.reversed.map((e) => ListTile(
                                    title: SelectableText(e.title),
                                    subtitle: SelectableText(e.message),
                                  )).toList(),
                                ),
                              ),
                            ]
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Audio tab with volume control, show audio devices, connected devices, each audio source
                              Expanded(
                                child: ListView(
                                  children: [
                                    ListTile(
                                      title: Text("Master Volume"),
                                      subtitle: ListenableBuilder(
                                        listenable: audioManager.masterVolume,
                                        builder: (context, child) {
                                          return Slider(
                                            value: audioManager.masterVolume.value,
                                            onChanged: (value) {
                                              audioManager.masterVolume.value = value;
                                              Storage().write("masterVolume", value.toString());
                                            },
                                            max: 1.0,
                                            min: 0.0,
                                            divisions: 50,
                                            label: "${(audioManager.masterVolume.value * 100).round()}%",
                                          );
                                        }
                                      ),
                                    ),
                                    ListTile(
                                      title: Text("Music Volume"),
                                      subtitle: Slider(
                                        value: 0.5,
                                        onChanged: null,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text("Sound Effects Volume"),
                                      subtitle: Slider(
                                        value: 0.5,
                                        onChanged: null,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text("Voice Volume"),
                                      subtitle: Slider(
                                        value: 0.5,
                                        onChanged: null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ),
                      Text("Network"),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          DropdownMenu<ThemeItem>(
                            label: Text("Theme"),
                            dropdownMenuEntries: ThemeController.themes.map((e) => DropdownMenuEntry(value: e, label: e.name)).toList(),
                            initialSelection: ThemeController.themes.firstWhere((element) => element.name == ThemeController.of(context).currentThemeName),
                            onSelected: (value) {
                              if(value != null) {
                                ThemeController.of(context, listen: false).setTheme(value.value);
                                Storage().write("theme", value.name);
                              }
                            },
                            enableSearch: false,
                            enableFilter: false,
                          )
                        ],
                      )
                    ]
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
