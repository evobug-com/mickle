

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:talk/core/version.dart';
import 'package:talk/main.dart';
import 'package:http/http.dart' as http;
import "package:path_provider/path_provider.dart";
import 'package:window_manager/window_manager.dart';

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

class LatestVersionData extends ChangeNotifier {
  static LatestVersionData? _instance = LatestVersionData._();

  LatestVersionData._();

  factory LatestVersionData() {
    return _instance!;
  }

  Future<http.Response>? future;
  dynamic? data;

  void fetchLatestVersion() {
    future = http.get(Uri.parse("https://api.github.com/repos/siocom-cz/talk/releases/latest"), headers: {
      "Accept": "application/vnd.github.v3+json",
      "X-GitHub-Api-Version": "2022-11-28",
    });
    future!.then((value) {
      data = jsonDecode(value.body);
      notifyListeners();
    }).catchError((e) {
      data = e;
      notifyListeners();
    });
    notifyListeners();
  }

  getCurrentPlatformAsset() {
    final platform = Platform.operatingSystem;
    return data["assets"].firstWhere((element) => element["name"] == "${platform}-release.zip");
  }

  Future<Uint8List> downloadAsset() {
    final asset = getCurrentPlatformAsset();
    return http.readBytes(Uri.parse(asset["browser_download_url"]));
  }

  unzipAsset(Uint8List rawData) async {
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
      final script = File("${distDir}${Platform.pathSeparator}autoupdate.bat");
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
      final script = File("${distDir}${Platform.pathSeparator}autoupdate.sh");
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

  get latestVersion {
    return data["tag_name"].substring(1);
  }
}

class UpdaterScreen extends StatefulWidget {
  const UpdaterScreen({super.key});

  @override
  _UpdaterScreenState createState() => _UpdaterScreenState();
}

class _UpdaterScreenState extends State<UpdaterScreen> {

  @override
  void initState() {
    super.initState();
    print(Platform.resolvedExecutable);
    LatestVersionData().fetchLatestVersion();
  }

  @override
  Widget build(BuildContext context) {

    return UpdaterScaffold(body:
      ListenableBuilder(
        listenable: LatestVersionData(),
        builder: (context, _) {
          return FutureBuilder(
            future: LatestVersionData().future,
            builder: (context, snapshot) {
              if(snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Siocom Talk"),
                      Text("Verze ${version}"),
                      Text("Nepodařilo se načíst novou verzi:"),
                      SelectableText("${snapshot.error}"),
                      ElevatedButton(
                        onPressed: () {
                          LatestVersionData().fetchLatestVersion();
                        },
                        child: Text("Znovu načíst"),
                      ),
                    ],
                  ),
                );
              }

              if(!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Siocom Talk"),
                      Text("Verze ${version}"),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }

              final latestVersion = LatestVersionData();

              if (latestVersion.latestVersion != version) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Autoupdate will show current version, latest version, and changelog, using material3 components
                    // Make it look good and modern
                    children: [
                      Text("Siocom Talk"),
                      Text("Verze ${version}"),
                      Text("Poslední verze: ${latestVersion.latestVersion}"),
                      ElevatedButton(
                        onPressed: () async {
                          final data = await latestVersion.downloadAsset();
                          await latestVersion.unzipAsset(data);
                          await latestVersion.swapAssets();
                        },
                        child: Text("Aktualizovat"),
                      ),

                    ],
                  ),
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Siocom Talk"),
                    Text("Verze ${version}"),
                    Text("Je to nejnovější verze!"),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Surprise!"),
                    ),
                  ],
                ),
              );
            }
          );
        }
      ));
  }
}