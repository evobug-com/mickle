import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mickle/core/storage/secure_storage.dart';

import 'data/endpoint.dart';
import 'storage.dart';

const defaultValues = {
  'lastVisitedServerId': '',
  'isFirstTime': true,
  'updateChannel': 'stable',
};

class Preferences {
  static final Storage _storage = Storage();
  static final SecureStorage _secureStorage = SecureStorage();

  static Future<String> getLastVisitedServerId() async {
    return (await _storage.getString("lastVisitedServerId")) ?? defaultValues['lastVisitedServerId'] as String;
  }

  static Future<void> setLastVisitedServerId(String serverId) async {
    return _storage.setString("lastVisitedServerId", serverId);
  }

  static Future<bool> getIsFirstTime() async {
    return (await _storage.getBool("isFirstTime")) ?? defaultValues['isFirstTime'] as bool;
  }

  static Future<void> setIsFirstTime(bool isFirstTime) async {
    return _storage.setBool("isFirstTime", isFirstTime);
  }

  static Future<String> getUpdateChannel() async {
    return (await _storage.getString("updateChannel")) ?? defaultValues['updateChannel'] as String;
  }

  static Future<void> setUpdateChannel(String channel) async {
    return _storage.setString("updateChannel", channel);
  }

  static Future<List<String>> getEndpoints() async {
    return (await _secureStorage.getStringList("endpoints")) ?? [];
  }

  static Future<void> setEndpoints(List<String> endpoints) async {
    return _secureStorage.setStringList("endpoints", endpoints);
  }

  static Future<PreferenceEndpoint?> getEndpoint(String endpoint) async {
    final json = await _secureStorage.getString("endpoints.$endpoint");
    if(json == null) return null;
    return PreferenceEndpoint.fromJson(jsonDecode(json));
  }

  static Future<void> removeEndpoint(String endpoint) async {
    return _secureStorage.remove("endpoints.$endpoint");
  }

  static Future<void> setEndpoint(String endpoint, PreferenceEndpoint data) async {
    return _secureStorage.setString("endpoints.$endpoint", jsonEncode(data));
  }
}

// Widget to get Async Preferences and Settings Async Preferences
class PreferenceProvider<TGet, TSet> extends StatelessWidget {
  final Future<TGet> Function() get;
  final Future<void> Function(TSet data)? set;
  final Function(void Function() callback)? setState;
  final Widget Function(BuildContext context, TGet data, Future<void> Function(TSet data) setData) builder;

  const PreferenceProvider({super.key, required this.get, this.set, required this.builder, this.setState});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: get(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return builder(context, snapshot.data as TGet, (data) async {
            if(set != null) {
              if(setState != null) {
                final completer = Completer<void>();
                setState!(() {
                  set!(data).then((value) => completer.complete());
                });
                return completer.future;
              } else {
                return set!(data);
              }
            }
          });
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}