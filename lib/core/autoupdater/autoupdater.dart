import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:talk/core/autoupdater/github.dart';
import 'package:talk/core/autoupdater/github.jsondata.dart';
import 'package:talk/core/autoupdater/version.dart';
import 'package:talk/core/version.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:talk/core/autoupdater/scripts.dart';
import 'package:logging/logging.dart';

class UpdateInfo {
  final bool updateAvailable;
  final GithubRelease? latestRelease;
  final SemVer? latestVersion;
  final int? updateSize;

  UpdateInfo({
    required this.updateAvailable,
    this.latestRelease,
    this.latestVersion,
    this.updateSize,
  });

  String getReleaseNotes() {
    if (latestRelease == null) return '';
    return latestRelease!.body ?? '';
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
  bool _dryRun = false;
  SemVer? _fakeVersion;
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

  void setDryRun(bool dryRun, {SemVer? fakeVersion}) {
    _logger.info('Dry run mode: $dryRun');
    _dryRun = dryRun;
    _fakeVersion = fakeVersion;
  }

  /// Checks for updates and returns update information.
  Future<UpdateInfo> checkForUpdates() async {
    try {
      final currentVersion = SemVer.fromString(version);
      GithubRelease? latestRelease;
      SemVer? latestVersion;

      if (_dryRun && _fakeVersion != null) {
        latestVersion = _fakeVersion;
        latestRelease = _createFakeRelease(latestVersion!);
      } else {
        latestRelease = await Github.fetchLatestRelease();
        latestVersion = _parseVersion(latestRelease.tagName);
      }

      if (latestVersion > currentVersion) {
        _updateInfo = UpdateInfo(
          updateAvailable: true,
          latestRelease: latestRelease,
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

  GithubRelease _createFakeRelease(SemVer fakeVersion) {
    final now = DateTime.now().toIso8601String();
    final platform = _getPlatform();
    return GithubRelease(
      url: 'https://api.github.com/repos/yourusername/yourrepo/releases/1',
      htmlUrl: 'https://github.com/yourusername/yourrepo/releases/tag/v${fakeVersion.toString()}',
      assetsUrl: 'https://api.github.com/repos/yourusername/yourrepo/releases/1/assets',
      uploadUrl: 'https://uploads.github.com/repos/yourusername/yourrepo/releases/1/assets{?name,label}',
      tarballUrl: 'https://api.github.com/repos/yourusername/yourrepo/tarball/v${fakeVersion.toString()}',
      zipballUrl: 'https://api.github.com/repos/yourusername/yourrepo/zipball/v${fakeVersion.toString()}',
      id: 1,
      nodeId: 'MDc6UmVsZWFzZTE=',
      tagName: 'v${fakeVersion.toString()}',
      targetCommitish: 'main',
      name: 'Release v${fakeVersion.toString()}',
      body: 'This is a simulated release for dry run testing.\n\n- Feature 1\n- Bug fix 2\n- Improvement 3',
      draft: false,
      prerelease: false,
      createdAt: now,
      publishedAt: now,
      assets: [
        GithubReleaseAsset(
          url: 'https://api.github.com/repos/yourusername/yourrepo/releases/assets/1',
          browserDownloadUrl: 'https://github.com/yourusername/yourrepo/releases/download/v${fakeVersion.toString()}/$platform-release.zip',
          id: 1,
          nodeId: 'MDEyOlJlbGVhc2VBc3NldDE=',
          name: '$platform-release.zip',
          label: '$platform Release',
          state: 'uploaded',
          contentType: 'application/zip',
          size: 1024 * 1024, // 1 MB
          downloadCount: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      bodyHtml: '<p>This is a simulated release for dry run testing.</p><ul><li>Feature 1</li><li>Bug fix 2</li><li>Improvement 3</li></ul>',
      bodyText: 'This is a simulated release for dry run testing.\n\n- Feature 1\n- Bug fix 2\n- Improvement 3',
      mentionsCount: 0,
      discussionUrl: null,
    );
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
    if (_dryRun) {
      await Future.delayed(const Duration(seconds: 1));
    }
    updateProgress(ProgressInfo(progress: 1.0, message: 'Preparation complete'));
  }

  Future<void> _downloadStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Downloading update');
    if (_dryRun) {
      await _simulateDownload((progress, message, bytesProcessed, totalBytes, speed) {
        _logger.info('simulation: $message (${(progress * 100).toStringAsFixed(1)}%)');
        updateProgress(ProgressInfo(
          progress: progress,
          message: message,
          bytesProcessed: bytesProcessed,
          totalBytes: totalBytes,
          speed: speed,
        ));
      });
    } else {
      final downloadUrl = await _getDownloadUrl(_updateInfo!.latestRelease!, _platform!);
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
  }


  Future<void> _verifyStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Verifying update');
    if (_dryRun) {
      await Future.delayed(const Duration(seconds: 1));
    } else {
      // Implement actual verification logic here
      // For example, check file integrity, signatures, etc.
    }
    updateProgress(ProgressInfo(progress: 1.0, message: 'Verification complete'));
  }

  Future<void> _installStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Installing update');
    if (_dryRun) {
      await _simulateExtract((progress, message, bytesProcessed, totalBytes) {
        _logger.info('simulation: $message (${(progress * 100).toStringAsFixed(1)}%)');
        updateProgress(ProgressInfo(
          progress: progress,
          message: message,
          bytesProcessed: bytesProcessed,
          totalBytes: totalBytes,
        ));
      });
    } else {
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
  }

  Future<void> _finalizeStep(void Function(ProgressInfo) updateProgress) async {
    _logger.info('Finalizing update');
    if (_dryRun) {
      await Future.delayed(const Duration(seconds: 1));
      _logger.info('Dry run completed. The update would be applied now in a real scenario.');
    } else {
      await _applyUpdate(_platform!);
    }
    updateProgress(ProgressInfo(progress: 1.0, message: 'Update finalized'));
  }

  Future<void> _simulateDownload(
      void Function(double progress, String message, int bytesProcessed, int totalBytes, double speed) updateProgress
      ) async {
    const totalBytes = 100 * 1024 * 1024; // 100 MB
    int bytesProcessed = 0;
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      bytesProcessed = (totalBytes * i / 10).round();
      final speed = bytesProcessed / (i * 0.5); // bytes per second
      updateProgress(i * 0.1, 'Simulating download', bytesProcessed, totalBytes, speed);
    }
  }

  Future<void> _simulateExtract(
      void Function(double progress, String message, int bytesProcessed, int totalBytes) updateProgress
      ) async {
    const totalBytes = 200 * 1024 * 1024; // 200 MB (assuming extracted size is larger)
    int bytesProcessed = 0;
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      bytesProcessed = (totalBytes * i / 5).round();
      updateProgress(0.7 + i * 0.06, 'Simulating extraction', bytesProcessed, totalBytes);
    }
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

  SemVer _parseVersion(String version) => SemVer.fromString(version.substring(1));

  String _getPlatform() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isMacOS) return 'macos';
    throw UnsupportedError('Unsupported platform');
  }

  Future<Uri> _getDownloadUrl(GithubRelease release, String platform) async {
    final asset = release.assets.firstWhere((element) => element.name == '$platform-release.zip');
    return Uri.parse(asset.browserDownloadUrl);
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

  String _getDownloadPath(SemVer version, String platform) =>
      path.join(_getDownloadLocation(), 'talk-$version-$platform-release.zip');

  String _getUnzipPath(SemVer version, String platform) =>
      path.join(_getDownloadLocation(), 'talk-$version-$platform-release');
}