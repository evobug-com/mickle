import 'package:freezed_annotation/freezed_annotation.dart';
part 'endpoint.g.dart';

@JsonSerializable()
@Immutable()
class PreferenceEndpointTofu {
  @JsonKey()
  final String certificateFingerprint;
  @JsonKey()
  final String serverAddress;
  @JsonKey()
  final int serverPort;
  @JsonKey()
  final int protocolVersion;
  @JsonKey()
  final String publicKey;

  PreferenceEndpointTofu({required this.certificateFingerprint, required this.serverAddress, required this.serverPort, required this.protocolVersion, required this.publicKey});

  factory PreferenceEndpointTofu.fromJson(Map<String, dynamic> json) => _$PreferenceEndpointTofuFromJson(json);
  Map<String, dynamic> toJson() => _$PreferenceEndpointTofuToJson(this);

  @override
  String toString() {
    return 'PreferenceEndpointTofu{certificateFingerprint: $certificateFingerprint, serverAddress: $serverAddress, serverPort: $serverPort, protocolVersion: $protocolVersion, publicKey: $publicKey}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PreferenceEndpointTofu &&
      other.certificateFingerprint == certificateFingerprint &&
      other.serverAddress == serverAddress &&
      other.serverPort == serverPort &&
      other.protocolVersion == protocolVersion &&
      other.publicKey == publicKey;
  }

  @override
  int get hashCode {
    return certificateFingerprint.hashCode ^
      serverAddress.hashCode ^
      serverPort.hashCode ^
      protocolVersion.hashCode ^
      publicKey.hashCode;
  }

  PreferenceEndpointTofu? copyWith({
    String? certificateFingerprint,
    String? serverAddress,
    int? serverPort,
    int? protocolVersion,
    String? publicKey
  }) {
    return PreferenceEndpointTofu(
      certificateFingerprint: certificateFingerprint ?? this.certificateFingerprint,
      serverAddress: serverAddress ?? this.serverAddress,
      serverPort: serverPort ?? this.serverPort,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      publicKey: publicKey ?? this.publicKey
    );
  }
}

@JsonSerializable()
@Immutable()
class PreferenceEndpoint {
  @JsonKey()
  final String connectionUrl;
  @JsonKey()
  final String token;
  @JsonKey()
  final String serverName;
  @JsonKey()
  final String username;
  @JsonKey()
  final PreferenceEndpointTofu? tofuData;

  PreferenceEndpoint({required this.connectionUrl, required this.token, this.serverName = '', this.username = '', this.tofuData});

  factory PreferenceEndpoint.fromJson(Map<String, dynamic> json) => _$PreferenceEndpointFromJson(json);
  Map<String, dynamic> toJson() => _$PreferenceEndpointToJson(this);

  @override
  String toString() {
    return 'PreferenceEndpoint{connectionUrl: $connectionUrl, token: $token, serverName: $serverName, username: $username, tofuData: $tofuData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PreferenceEndpoint &&
      other.connectionUrl == connectionUrl &&
      other.token == token &&
      other.serverName == serverName &&
      other.username == username &&
      other.tofuData == tofuData;
  }

  @override
  int get hashCode {
    return connectionUrl.hashCode ^
      token.hashCode ^
      serverName.hashCode ^
      username.hashCode ^
      tofuData.hashCode;
  }

  PreferenceEndpoint? copyWith(
  {
    String? connectionUrl,
    String? token,
    String? serverName,
    String? username,
    PreferenceEndpointTofu? tofuData
  }) {
    return PreferenceEndpoint(
      connectionUrl: connectionUrl ?? this.connectionUrl,
      token: token ?? this.token,
      serverName: serverName ?? this.serverName,
      username: username ?? this.username,
      tofuData: tofuData ?? this.tofuData
    );
  }
}