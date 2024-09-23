import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:talk/core/autoupdater/version.dart';
import 'package:talk/core/storage/preferences.dart';
import 'package:talk/core/version.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:talk/core/autoupdater/scripts.dart';
import 'package:logging/logging.dart';

const baseUrl = 'http://vps.sionzee.cz:9001';

String _getPlatform() {
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  if (Platform.isMacOS) return 'macos';
  throw UnsupportedError('Unsupported platform');
}

class ReleaseInfo {
  final String version;
  final String notes;
  final DateTime pubDate;
  final Map<String, PlatformReleaseInfo> platforms;

  ReleaseInfo({
    required this.version,
    required this.notes,
    required this.pubDate,
    required this.platforms,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) {
    final platformsJson = json['platforms'] as Map<String, dynamic>;
    final platforms = platformsJson.map((key, value) => MapEntry(key, PlatformReleaseInfo.fromJson(value)));
    return ReleaseInfo(
      version: json['version'],
      notes: json['notes'],
      pubDate: DateTime.parse(json['pub_date']),
      platforms: platforms,
    );
  }
}

class PlatformReleaseInfo {
  final String url;
  final String signature;
  final int size;

  PlatformReleaseInfo({required this.url, required this.signature, required this.size});

  factory PlatformReleaseInfo.fromJson(Map<String, dynamic> json) {
    return PlatformReleaseInfo(
      url: json['url'],
      signature: json['signature'],
      size: json['size'],
    );
  }
}

class UpdateInfo {
  final bool updateAvailable;
  final ReleaseInfo? latestReleaseInfo;
  final SemVer? latestVersion;

  UpdateInfo({
    required this.updateAvailable,
    this.latestReleaseInfo,
    this.latestVersion,
  });

  String getReleaseNotes() {
    if (latestReleaseInfo == null) return '';
    return latestReleaseInfo!.notes;
  }

  PlatformReleaseInfo getCurrentPlatformInfo() {
    if (latestReleaseInfo == null) {
      throw Exception('No update available');
    }

    final platform = _getPlatform();
    final platformInfo = latestReleaseInfo!.platforms[platform];
    if (platformInfo == null) {
      throw Exception('No update available for platform $platform');
    }

    return platformInfo;
  }
}

class ProgressInfo {
  final double progress;
  final String message;
  final int? bytesProcessed;
  final int? totalBytes;
  final double? speed; // in bytes per second

  ProgressInfo({
    required this.progress,
    required this.message,
    this.bytesProcessed,
    this.totalBytes,
    this.speed,
  });
}

class AutoUpdater {
  static final AutoUpdater _instance = AutoUpdater._internal();
  final Logger _logger = Logger('AutoUpdater');
  UpdateInfo? _updateInfo;
  String? _downloadPath;
  String? _unzipPath;
  String? _platform;

  // Private constructor
  AutoUpdater._internal();

  // Factory constructor to return the same instance every time
  factory AutoUpdater() {
    return _instance;
  }

  UpdateInfo? get updateInfo => _updateInfo;

  /// Checks for updates and returns update information.
  Future<UpdateInfo> checkForUpdates() async {
    try {
      final currentVersion = SemVer.fromString(version);
      ReleaseInfo? latestReleaseInfo;
      SemVer? latestVersion;

      latestReleaseInfo = await _fetchLatestReleaseInfo(Preferences.updateChannel);
      latestVersion = SemVer.fromString(latestReleaseInfo.version);

      if (latestVersion > currentVersion) {
        _updateInfo = UpdateInfo(
          updateAvailable: true,
          latestReleaseInfo: latestReleaseInfo,
          latestVersion: latestVersion,
        );
      } else {
        _updateInfo = UpdateInfo(updateAvailable: false);
      }
    } catch (e) {
      _logger.severe('Auto-update check error: $e');
      _updateInfo = UpdateInfo(updateAvailable: false);
    }

    return _updateInfo!;
  }

  Future<ReleaseInfo> _fetchLatestReleaseInfo(String channel) async {
    final url = Uri.parse('$baseUrl/updates/$channel/latest');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final releaseInfo = ReleaseInfo.fromJson(json);
      return releaseInfo;
    } else {
      throw HttpException('Failed to fetch latest release info: ${response.statusCode}');
    }
  }

  /// Performs the update process.
  Future<void> prepareUpdate() async {
    if (_updateInfo == null || !_updateInfo!.updateAvailable) {
      throw Exception('No update available');
    }

    _platform = _getPlatform();
    _downloadPath = _getDownloadPath(_updateInfo!.latestVersion!, _platform!);
    _unzipPath = _getUnzipPath(_updateInfo!.latestVersion!, _platform!);
  }

  Future<void> performUpdateStep(int step, void Function(ProgressInfo) updateProgress) async {
    if (_updateInfo == null || !_updateInfo!.updateAvailable) {
      throw Exception('No update available');
    }

    switch (step) {
      case 0:
        updateProgress(ProgressInfo(progress: 0.0, message: ''));
        await _prepareStep(updateProgress);
        break;
      case 1:
        updateProgress(ProgressInfo(progress: 0.0, message: ''));
        await _downloadStep(updateProgress);
        break;
      case 2:
        updateProgress(ProgressInfo(progress: 0.0, message: ''));
        await _verifyStep(updateProgress);
        break;
      case 3:
        updateProgress(ProgressInfo(progress: 0.0, message: ''));
        await _installStep(updateProgress);
        break;
      case 4:
        updateProgress(ProgressInfo(progress: 0.0, message: ''));
        await _finalizeStep(updateProgress);
        break;
      default:
        throw Exception('Invalid update step');
    }
  }

  Future<void> _prepareStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Preparing for update');
    await prepareUpdate();
    updateProgress(ProgressInfo(progress: 1.0, message: 'Preparation complete'));
  }

  Future<void> _downloadStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Downloading update');
    final downloadUrl = _getDownloadUrl(_updateInfo!.latestReleaseInfo!, _platform!);
    await _downloadAsset(downloadUrl, _downloadPath!, (progress, bytesProcessed, totalBytes, speed) {
      final message = 'Downloading: ${(progress * 100).toStringAsFixed(1)}%';
      _logger.info(message);
      updateProgress(ProgressInfo(
        progress: progress,
        message: message,
        bytesProcessed: bytesProcessed,
        totalBytes: totalBytes,
        speed: speed,
      ));
    });
  }

  Future<void> _verifyStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Verifying update');
    // Implement verification logic here
    // For example, compute SHA256 hash of the downloaded file and compare with signature
    updateProgress(ProgressInfo(progress: 1.0, message: 'Verification complete'));
  }

  Future<void> _installStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Installing update');
    final rawData = await File(_downloadPath!).readAsBytes();
    await _unzipAsset(rawData, _unzipPath!, (progress, bytesProcessed, totalBytes) {
      final message = 'Extracting: ${(progress * 100).toStringAsFixed(1)}%';
      updateProgress(ProgressInfo(
        progress: progress,
        message: message,
        bytesProcessed: bytesProcessed,
        totalBytes: totalBytes,
      ));
    });
    await _createUpdateScript(_platform!, _unzipPath!);
  }

  Future<void> _finalizeStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Finalizing update');
    await _applyUpdate(_platform!);
    updateProgress(ProgressInfo(progress: 1.0, message: 'Update finalized'));
  }

  /// Creates the update script based on the platform.
  Future<void> _createUpdateScript(String platform, String sourcePath) async {
    final scriptContent = platform == 'windows' ? windowsUpdateScript : linuxUpdateScript;
    final scriptExtension = platform == 'windows' ? '.bat' : '.sh';
    final scriptPath = path.join(_getDownloadLocation(), 'updateSiocomTalk$scriptExtension');

    await File(scriptPath).writeAsString(scriptContent);

    if (platform != 'windows') {
      await Process.run('chmod', ['+x', scriptPath]);
    }
  }

  /// Applies the update by running the update script.
  Future<void> _applyUpdate(String platform) async {
    final scriptExtension = platform == 'windows' ? '.bat' : '.sh';
    final scriptPath = path.join(_getDownloadLocation(), 'updateSiocomTalk$scriptExtension');
    final sourcePath = path.dirname(Platform.resolvedExecutable);
    final destPath = path.dirname(sourcePath);

    final command = platform == 'windows'
        ? [scriptPath, destPath, sourcePath]
        : ['bash', scriptPath, destPath, sourcePath];

    await Process.start(
      command.first,
      command.skip(1).toList(),
      mode: ProcessStartMode.detached,
      workingDirectory: _getDownloadLocation(),
    );

    exit(0);
  }

  /// Unzips the downloaded asset.
  Future<void> _unzipAsset(
      Uint8List rawData,
      String unzipPath,
      void Function(double progress, int bytesProcessed, int totalBytes) updateProgress
      ) async {
    final archive = ZipDecoder().decodeBytes(rawData);
    final totalBytes = archive.files.fold<int>(0, (sum, file) => sum + file.size);
    var bytesProcessed = 0;

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      if (archiveFile.isFile) {
        final data = archiveFile.content as List<int>;
        final file = File(path.join(unzipPath, filename));
        await file.create(recursive: true);
        await file.writeAsBytes(data);
        bytesProcessed += archiveFile.size;
        updateProgress(bytesProcessed / totalBytes, bytesProcessed, totalBytes);
      } else {
        final dir = Directory(path.join(unzipPath, filename));
        await dir.create(recursive: true);
      }
    }
  }

  String _getDownloadLocation() => Directory.systemTemp.path;

  Uri _getDownloadUrl(ReleaseInfo releaseInfo, String platform) {
    final platformInfo = releaseInfo.platforms[platform];
    if (platformInfo == null) {
      throw Exception('No update available for platform $platform');
    }
    return Uri.parse(platformInfo.url);
  }

  Future<void> _downloadAsset(
      Uri uri,
      String path,
      void Function(double progress, int bytesProcessed, int totalBytes, double speed) updateProgress
      ) async {
    final request = http.Request('GET', uri);
    final response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final file = File(path);
      final sink = file.openWrite();
      final contentLength = response.contentLength ?? 0;
      var downloaded = 0;
      final stopwatch = Stopwatch()..start();

      await response.stream.forEach((List<int> chunk) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (contentLength > 0) {
          final progress = downloaded / contentLength;
          final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000;
          final speed = downloaded / elapsedSeconds;
          updateProgress(progress, downloaded, contentLength, speed);
        }
      });

      await sink.close();
    } else {
      throw HttpException('Failed to download asset: ${response.statusCode}');
    }
  }

  String _getDownloadPath(SemVer version, String platform) {
    final platformInfo = _updateInfo!.latestReleaseInfo!.platforms[platform]!;
    final url = platformInfo.url;
    final filename = path.basename(url);
    return path.join(_getDownloadLocation(), filename);
  }

  String _getUnzipPath(SemVer version, String platform) {
    final filenameWithoutExtension = path.basenameWithoutExtension(_downloadPath!);
    return path.join(_getDownloadLocation(), filenameWithoutExtension);
  }
}