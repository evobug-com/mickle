// Console is a overlay that can be used to display messages, errors, and warnings.
// It can be used to control the audio volume, etc...

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/network/utils.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/storage/storage.dart';
import 'package:talk/core/network/request.dart' as request;
import 'package:talk/main.dart';
import 'package:talk/globals.dart' as globals;

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
  bool _autoStartup = false;

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
    _init();
  }

  _init() async {
    _autoStartup = await launchAtStartup.isEnabled();
    _newDisplayNameController.text = CurrentSession().connection?.user?.displayName ?? '';
    setState(() {});
  }

  isEnableAutoStartup() {
    return _autoStartup;
  }

  setAutoStartup(bool value) async {
    if(value) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
    _autoStartup = value;
    setState(() {});
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
                // Tile to launch auto updater
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text("Spustit vyhledávání aktualizací"),
                  onTap: () {
                    globals.isUpdater = true;
                    context.go("/updater");
                    updateWindowStyle();
                  },
                ),
                // Auto startup
                ListTile(
                  leading: const Icon(Icons.autorenew),
                  title: const Text("Spustit při startu systému"),
                  trailing: Switch(
                    value: isEnableAutoStartup(),
                    onChanged: setAutoStartup,
                  ),
                ),
                // Change password
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Změnit heslo"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Změna hesla"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Staré heslo",
                                  ),
                                  obscureText: true,
                                  controller: _oldPasswordController,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Nové heslo",
                                  ),
                                  obscureText: true,
                                  controller: _newPasswordController,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Potvrzení hesla",
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
                                child: const Text("Zrušit"),
                              ),
                              TextButton(
                                onPressed: () {

                                  // Check if password is not empty, show toast if it is
                                  if(_newPasswordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password cannot be empty")));
                                    return;
                                  }

                                  // Check if password is valid, show toast if not
                                  if(_newPasswordController.text != _confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                                    return;
                                  }

                                  CurrentSession().connection!.send(request.ChangePassword(
                                    requestId: getNewRequestId(),
                                    oldPassword: _oldPasswordController.text,
                                    newPassword: _newPasswordController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: const Text("Potvrdit"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Změnit zobrazovací jméno"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Změna zobrazovacího jména"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Nové zobrazovací jméno",
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
                                child: const Text("Zrušit"),
                              ),
                              TextButton(
                                onPressed: () {

                                  // Check if display name is not empty, show toast if it is
                                  if(_newDisplayNameController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Display name cannot be empty")));
                                    return;
                                  }

                                  CurrentSession().connection!.send(request.ChangeDisplayName(
                                    requestId: getNewRequestId(),
                                    displayName: _newDisplayNameController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: const Text("Potvrdit"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Change status
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Změnit status"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Změna statusu"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Nový status",
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
                                child: const Text("Zrušit"),
                              ),
                              TextButton(
                                onPressed: () {

                                  CurrentSession().connection!.send(request.ChangeStatus(
                                    requestId: getNewRequestId(),
                                    status: _newStatusController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: const Text("Potvrdit"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Change avatar
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Změnit avatar"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Změna avataru"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Adresa obrázku",
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
                                child: const Text("Zrušit"),
                              ),
                              TextButton(
                                onPressed: () {

                                  CurrentSession().connection!.send(request.ChangeAvatar(
                                    requestId: getNewRequestId(),
                                    avatar: _newAvatarController.text,
                                  ).serialize());

                                  Navigator.of(context).pop();
                                },
                                child: const Text("Potvrdit"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Change presence (pick from online, away, do not disturb, etc...)
                ListTile(
                  leading: const Icon(Icons.circle),
                  title: const Text("Změnit přítomnost"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Změna přítomnosti"),
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
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Change"),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                // Divider
                const Divider(),
                // Heading with section with padding to show list of roles
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Seznam rolí", style: TextStyle(fontSize: 20)),
                    ...Database(CurrentSession().server!.id).roles.items.map((role) {
                      final users = role.getUsers();
                      final permissions = role.getPermissions();
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text("${role.name} (${users.length})"),
                              subtitle: Text("Váha: ${role.rank}"),
                            ),
                            const Divider(),
                            // Foldable section with permissions
                            ExpansionTile(
                              title: const Text("Oprávnění"),
                              children: [
                                // Display all permissions with checkboxes, group them by category
                                ...Database(CurrentSession().server!.id).permissions.items.groupListsBy((permission) => permission.category).entries.map((entry) {
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
                                                title: Text(permission.name),
                                                value: permissions.contains(permission),
                                                dense: true,
                                                onChanged: (value) {
                                                  // if(value) {
                                                  //   role.addPermission(permission);
                                                  // } else {
                                                  //   role.removePermission(permission);
                                                  // }
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
                                // Display all users in the role, with ability to remove them and add new ones
                                ...users.map((user) {
                                  return ListTile(
                                    title: Text(user.displayName!),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        // role.removeUser(user);
                                      },
                                    ),
                                  );
                                }),
                              ],
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ],
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Konzole", style: TextStyle(fontSize: 20)),
              Text("Zde můžete vidět chyby, upozornění, atd...", style: TextStyle(fontSize: 16)),
            ],
          ),
          const Divider(),
          // Audio section
          DefaultTabController(
            length: 5,
            child: Expanded(
              child: Column(
                children: [
                  const TabBar(
                    // The tab is at the top of the screen
                    tabs: [
                      Tab(text: "Obecné"),
                      Tab(text: "Chyby"),
                      Tab(text: "Zvuk"),
                      Tab(text: "Síť"),
                      Tab(text: "Nastavení"),
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
                                      title: const Text("Master Volume"),
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
                                    const ListTile(
                                      title: Text("Music Volume"),
                                      subtitle: Slider(
                                        value: 0.5,
                                        onChanged: null,
                                      ),
                                    ),
                                    const ListTile(
                                      title: Text("Sound Effects Volume"),
                                      subtitle: Slider(
                                        value: 0.5,
                                        onChanged: null,
                                      ),
                                    ),
                                    const ListTile(
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
                      const Text("Network tab with network statistics, ping, latency, etc..."),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          DropdownMenu<ThemeItem>(
                            label: const Text("Vzhled aplikace"),
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
