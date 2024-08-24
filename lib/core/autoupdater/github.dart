import 'dart:convert';

import 'package:http/http.dart' as http;

import 'github.jsondata.dart';

class Github {
  static Future<GithubRelease> fetchLatestRelease() {
    var url = Uri.parse("https://api.github.com/repos/siocom-cz/talk/releases/latest");
    var response = http.get(
        url,
        headers: {
          "Accept": "application/vnd.github.v3+json",
          "X-GitHub-Api-Version": "2022-11-28",
        }
    );

    return response.then((value) {
      if (value.statusCode == 200) {
        return GithubRelease.fromJson(jsonDecode(value.body));
      } else {
        throw Exception("Failed to fetch latest release");
      }
    });
  }
}