import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mickle/core/autoupdater/autoupdater.dart';
import 'package:mickle/core/autoupdater/version.dart';

class UpdateProvider extends ChangeNotifier {
  UpdateInfo _updateInfo;
  SemVer? _skippedVersion;

  UpdateProvider({required UpdateInfo updateInfo}) : _updateInfo = updateInfo;

  UpdateInfo get updateInfo => _updateInfo;
  bool get updateAvailable => _updateInfo.updateAvailable && _updateInfo.latestVersion != _skippedVersion;

  void setUpdateInfo(UpdateInfo updateInfo) {
    _updateInfo = updateInfo;
    if (_updateInfo.latestVersion != _skippedVersion) {
      notifyListeners();
    }
  }

  void skipUpdate() {
    if (_updateInfo.latestVersion != null) {
      _skippedVersion = _updateInfo.latestVersion;
      notifyListeners();
    }
  }

  void resetSkippedUpdate() {
    _skippedVersion = null;
    notifyListeners();
  }

  static UpdateProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<UpdateProvider>(context, listen: listen);
  }
}