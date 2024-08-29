import 'package:talk/core/network/api_types.dart';

import '../database.dart';


class PacketError {
  final String message;

  PacketError(this.message);

  factory PacketError.fromJson(Map<String, dynamic> json) {
    return PacketError(json['message'] as String);
  }

  Map<String, dynamic> toJson() => {'message': message};
}

class ApiResponse<T> {
  final int? requestId;
  final T? data;
  final PacketError? error;
  final String type;

  ApiResponse({required this.requestId, required this.type, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      requestId: json['request_id'] as int?,
      type: json['type'] as String,
      data: json['data'],
      error: json['error'] != null ? PacketError(json['error'] as String) : null,
    );
  }

  factory ApiResponse.success(T data, int? requestId, String type) =>
      ApiResponse(requestId: requestId, data: data, type: type);

  factory ApiResponse.error(String message, int? requestId, String type) =>
      ApiResponse(requestId: requestId, error: PacketError(message), type: type);

  bool get isSuccess => error == null;

  cast<TSub>(TSub Function(Map<String, dynamic> json) fromJson) {
    return ApiResponse<TSub>(
      requestId: requestId,
      type: type,
      data: data != null ? fromJson(data as Map<String, dynamic>) : null,
      error: error,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{requestId: $requestId, data: ${data?.toString()}, error: $error, type: $type}';
  }
}


List<String> parseMessageMentions(String message, {required Database database}) {
  // Parse message mentions
  List<String> rawMentions = RegExp(r'@(\w+)').allMatches(message).map((e) => e.group(1)).where((e) => e != null).toList().cast();

  // Replace mention with user id
  List<String> mentions = rawMentions.map((e) {
    return database.users.firstWhereOrNull((element) => element.displayName == e)?.id;
  }).where((e) => e != null).toList().cast();


  return mentions;
}