import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/version.dart';
import 'package:http/http.dart' as http;
import "package:path_provider/path_provider.dart";
import 'package:window_manager/window_manager.dart';
import 'package:talk/globals.dart' as globals;

import '../layout/updater_scaffold.dart';
import '../utils.dart';

const String windowsBat = """
@echo off
:: Ensure script is run as administrator
:: net session >nul 2>&1
:: if %errorlevel% neq 0 (
::     echo This script requires administrator privileges.
::     exit /b 1
:: )

:: Wait for a moment to ensure the application has exited
timeout /t 1 /nobreak >nul

:: Parameters
set "SOURCE_DIR=%~2"
set "DEST_DIR=%~1"

:: Change to the destination directory to handle relative paths effectively
pushd %DEST_DIR%

:: Clear destination directory, but keep the autoupdate.bat file
echo Deleting contents of %DEST_DIR%, except autoupdate.bat
for /D %%x in (*) do if /I not "%%x"=="autoupdate.bat" rd /s /q "%%x"
for %%x in (*) do if /I not "%%x"=="autoupdate.bat" del "%%x"

popd

:: Move new content to destination directory
echo Moving contents from %SOURCE_DIR% to %DEST_DIR%
xcopy /s /e /q /y "%SOURCE_DIR%\\*" "%DEST_DIR%\\"
echo Update complete.
start "" "%DEST_DIR%\\talk.exe"
exit /b 0
""";

const String unixSh = """
#!/bin/bash

# Check if the script is running as root
# if [ "\$(id -u)" != "0" ]; then
#    echo "This script must be run as root" 1>&2
#    exit 1
# fi

# Validate input parameters
if [ \$# -ne 2 ]; then
    echo "Usage: \$0 [destination directory] [source directory]"
    exit 1
fi

# Delay to ensure the application has fully exited
echo "Waiting for the application to exit..."
sleep 1

DEST_DIR="\$1"
SOURCE_DIR="\$2"

# The name of this script
SELF=\$(basename "\$0")

# Delete the contents of the destination directory except for the script itself
echo "Deleting contents of \$DEST_DIR except for \$SELF"
find "\$DEST_DIR" -mindepth 1 -maxdepth 1 ! -name "\$SELF" -exec rm -rf {} \;

# Move new content to destination directory
echo "Moving contents from \$SOURCE_DIR to \$DEST_DIR"
cp -a "\$SOURCE_DIR"/. "\$DEST_DIR"/

echo "Update complete."
start "" "\$DEST_DIR/talk"
""";

Future fakeFetchLatestVersion() {
  return Future.delayed(const Duration(seconds: 2), () async
  {
    String data = jsonEncode({
      "tag_name": "v$version",
      "assets": [
        {
          "name": "windows-release.zip",
          "browser_download_url": ""
        }
      ]
    });
    return http.Response(data, 200);
  });
}

Future fetchLatestVersion() {
  return http.get(Uri.parse("https://api.github.com/repos/siocom-cz/talk/releases/latest"), headers: {
    "Accept": "application/vnd.github.v3+json",
    "X-GitHub-Api-Version": "2022-11-28",
  });
}

getCurrentPlatformAsset(dynamic data) {
  final platform = Platform.operatingSystem;
  return data["assets"].firstWhere((element) => element["name"] == "$platform-release.zip");
}

Future<Uint8List> downloadAsset(dynamic data) {
  final asset = getCurrentPlatformAsset(data);
  return http.readBytes(Uri.parse(asset["browser_download_url"]));
}

Future<void> unzipAsset(Uint8List rawData) async {
  final tempDir = await getTemporaryDirectory();
  final archive = ZipDecoder().decodeBytes(rawData);
  for (final file in archive) {
    final filename = "${tempDir.path}${Platform.pathSeparator}siocom${Platform.pathSeparator}talk${Platform.pathSeparator}${file.name}";
    print("Extracting $filename");
    if (file.isFile) {
      final data = file.content as List<int>;
      final outputStream = OutputFileStream(filename);
      outputStream.writeBytes(Uint8List.fromList(data));
      outputStream.close();
    } else {
      Directory(filename).createSync(recursive: true);
    }
  }
}

Future<void> swapAssets() async {
  final tempDir = await getTemporaryDirectory();
  final distDir = Platform.resolvedExecutable.substring(0, Platform.resolvedExecutable.lastIndexOf(Platform.pathSeparator));

  // Write the update script next to the .exe file and make it executable on Unix
  // Run the script with the destination directory as the first argument and the source directory as the second argument
  if(Platform.isWindows) {
    final script = File("$distDir${Platform.pathSeparator}autoupdate.bat");
    script.writeAsStringSync(windowsBat);
    String sourceDir = "${tempDir.path}${Platform.pathSeparator}siocom${Platform.pathSeparator}talk${Platform.pathSeparator}build${Platform.pathSeparator}${Platform.operatingSystem}";
    print("Running ${script.path} \"$distDir\" \"$sourceDir\"");
    Process.start(
      "start",
      [script.path, distDir, sourceDir],
      runInShell: true,
      mode: ProcessStartMode.detached,
      workingDirectory: distDir,
    );
    windowManager.close();
    return;
  } else {
    final script = File("$distDir${Platform.pathSeparator}autoupdate.sh");
    script.writeAsStringSync(unixSh);
    Process.runSync("chmod", ["+x", script.path]);
    Process.start(
      script.path,
      [distDir, "${tempDir.path}${Platform.pathSeparator}siocom${Platform.pathSeparator}talk"],
      runInShell: true,
      mode: ProcessStartMode.detached,
      workingDirectory: distDir,
    );
    windowManager.close();
    return;
  }
}

void goToMain(BuildContext context) {
  context.go('/chat');
  globals.isUpdater = false;
  updateWindowStyle();
}

enum UpdatePhase {
  fetching,
  downloading,
  extracting,
  swapping,
  done
}

class UpdateModel extends ChangeNotifier {
  UpdatePhase _currentPhase = UpdatePhase.fetching;
  String? _errorMessage;
  bool _isAborted = false;
  late Future future;
  dynamic json;
  bool done = false;
  late Uint8List zippedData;

  UpdatePhase get currentPhase => _currentPhase;
  String? get errorMessage => _errorMessage;

  UpdateModel run() {
    performFetching();
    return this;
  }

  String latestVersion() {
    return json["tag_name"].substring(1);
  }

  void performFetching() {
    if(_isAborted) return;
    _currentPhase = UpdatePhase.fetching;
    future = fetchLatestVersion();
    future.then((value) {
      // Value is the response from the server
      json = jsonDecode(value.body);

      // Check if we have the latest version
      if(version == latestVersion()) {
        done = true;
        notifyListeners();
        return;
      }

      performDownloading();
    }).catchError((error) {
      setError(error.toString());
    });
    // Perform the fetching phase
    notifyListeners();
  }

  void performDownloading() {
    if(_isAborted) return;
    _currentPhase = UpdatePhase.downloading;
    future = downloadAsset(json);
    future.then((value) {
      zippedData = value;
      performExtracting();
    }).catchError((error) {
      setError(error.toString());
    });
    // Perform the downloading phase
    notifyListeners();
  }

  void performExtracting() {
    if(_isAborted) return;
    _currentPhase = UpdatePhase.extracting;
    future = unzipAsset(zippedData);
    future.then((value) {
      performSwapping();
    }).catchError((error) {
      setError(error.toString());
    });
    // Perform the extracting phase
    notifyListeners();
  }

  void performSwapping() {
    if(_isAborted) return;
    _currentPhase = UpdatePhase.swapping;
    future = swapAssets();
    future.then((value) {
      performDone();
    }).catchError((error) {
      setError(error.toString());
    });
    // Perform the swapping phase
    notifyListeners();
  }

  void performDone() {
    _currentPhase = UpdatePhase.done;
    // Perform the done phase
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void abort() {
    _isAborted = true;
  }
}

class UpdaterScreen extends StatefulWidget {
  const UpdaterScreen({super.key});

  @override
  State<UpdaterScreen> createState() => _UpdaterScreenState();
}

class _UpdaterScreenState extends State<UpdaterScreen> {

  @override
  Widget build(BuildContext context) {
    return UpdaterScaffold(
      body: ChangeNotifierProvider(
        create: (context) => UpdateModel().run(),
        child: Consumer<UpdateModel>(
          builder: (context, value, child) {
            return FutureBuilder(
              future: value.future,
              builder: (context, snapshot) {
                getStepState(UpdatePhase phase) {
                  if(value.currentPhase.index > phase.index) return StepState.complete;
                  if(value.currentPhase == phase) {
                    if(snapshot.connectionState == ConnectionState.done) {
                      return StepState.complete;
                    }

                    if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
                      return StepState.editing;
                    }

                    if(snapshot.hasError) {
                      return StepState.error;
                    }

                    return StepState.indexed;
                  }
                  return StepState.disabled;
                }
                getTitle(UpdatePhase phase) {
                  String text;
                  switch(phase) {
                    case UpdatePhase.fetching:
                      text = "Vyhledávání nejnovější verze (${value.json != null ? "v${value.latestVersion()}" : "-"})";
                      break;
                    case UpdatePhase.downloading:
                      text = "Stahování aktualizace";
                      break;
                    case UpdatePhase.extracting:
                      text = "Instalace aktualizace";
                      break;
                    case UpdatePhase.swapping:
                      text = "Restartování aplikace";
                      break;
                    case UpdatePhase.done:
                      text = "Hotovo";
                      break;
                  }
                  return Text(text);
                }
                getBody(num index, UpdatePhase phase) {
                  if(value.done && phase == UpdatePhase.fetching) {
                    return Column(
                      children: [
                        Text("Jste na nejnovější verzi aplikace"),
                        ElevatedButton(onPressed: () {
                          goToMain(context);
                        }, child: Text("Zavřít"))
                      ],
                    );
                  }

                  if(value.currentPhase == phase) {
                    return Column(
                      children: [
                        if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) CircularProgressIndicator(),
                        if(snapshot.hasError) Text("Chyba: ${snapshot.error}"),
                      ],
                    );
                  }

                  return Container();
                }
                return Stepper(
                    controlsBuilder: (context, details) {
                      return Row(
                        children: [
                          if(value.currentPhase != UpdatePhase.done && !value.done) ElevatedButton(
                            onPressed: value._isAborted ? null : () {
                              value.abort();
                              goToMain(context);
                            },
                            child: const Text("Přerušit"),
                          ),

                          if(value._isAborted)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text("Přerušeno"),
                            ),
                        ],
                      );
                    },
                    type: StepperType.vertical,
                    currentStep: value.currentPhase.index,
                    onStepTapped: null,
                    steps: UpdatePhase.values.mapIndexed((index, phase) {
                      return Step(
                        title: getTitle(phase),
                        state: getStepState(phase),
                        isActive: value.currentPhase == phase,
                        content: getBody(index, phase),
                      );
                    }).toList());
              },
            );
          },
        ),
      ),
    );
  }
}