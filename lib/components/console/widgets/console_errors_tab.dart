import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk/screens/settings_screen/settings_provider.dart';

import '../../../core/managers/audio_manager.dart';
import '../core/models/error_item.dart';

class Errors {
  static bool initialized = false;
  static List<ErrorItem> errors = [];
  static initialize() {
    if(initialized) return;
    initialized = true;
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      errors.add(ErrorItem(details.exceptionAsString(), details.stack.toString()));
      if(SettingsProvider().playSoundOnError) {
        AudioManager.playSingleShot("Master", AssetSource("audio/error.wav"));
      }
      if(originalOnError != null) {
        originalOnError(details);
      }
    };
  }

  static addError(String title, String message) {
    errors.add(ErrorItem(title, message));
  }
}

class ConsoleErrorsTab extends StatelessWidget {
  const ConsoleErrorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error tab with error messages, warnings, etc...
          Expanded(
            child: ListView(
              children: Errors.errors.reversed.map((e) => ListTile(
                title: SelectableText("${e.time} - ${e.title}"),
                subtitle: e.message.isEmpty ? null : SelectableText(e.message),
                isThreeLine: true,
                leading: const Icon(Icons.error),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: e.toString()));
                  },
                )
              )).toList(),
            ),
          ),
        ]
    );
  }
}