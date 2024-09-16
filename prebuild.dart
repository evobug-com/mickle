import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

abstract class ClassVisitor {
  String visit(DartClass dartClass);
}

class DartClass {
  final String name;
  final List<DartField> fields;
  final List<String> attributes;

  DartClass({required this.name, required this.fields, this.attributes = const []});
}

class DartField {
  final String name;
  final String type;
  final List<String> attributes;

  DartField({required this.name, required this.type, this.attributes = const []});
}

class DefaultClassVisitor implements ClassVisitor {
  @override
  String visit(DartClass dartClass) {
    final className = dartClass.name;
    final fields = _generateFields(dartClass.fields);
    final constructor = _generateConstructor(className, dartClass.fields);
    final toJsonMethod = _generateToJsonMethod(className);

    return '''
@JsonSerializable()
class $className with ChangeNotifier {
  $fields

  $constructor

  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);
  $toJsonMethod

  void notify() => notifyListeners();

  @override
  String toString() {
    return '$className{${_generateToString(dartClass.fields)}}';
  }
}
''';
  }

  String _generateFields(List<DartField> fields) {
    return fields.where((field) => !_shouldSkipField(field))
        .map((field) {
      final jsonKey = _generateJsonKey(field);
      final camelCaseName = ReCase(field.name).camelCase;
      return '$jsonKey\n  ${field.type} $camelCaseName;';
    }).join('\n  ');
  }

  String _generateConstructor(String className, List<DartField> fields) {
    final params = fields.where((field) => !_shouldSkipField(field))
        .map((field) {
      final camelCaseName = ReCase(field.name).camelCase;
      return field.type.endsWith('?') ? 'this.$camelCaseName,' : 'required this.$camelCaseName,';
    }).join('\n    ');

    return '$className({$params});';
  }

  String _generateToJsonMethod(String className) {
    return 'Map<String, dynamic> toJson() => _\$${className}ToJson(this);';
  }

  String _generateJsonKey(DartField field) {
    final jsonKeyParams = <String>[];
    jsonKeyParams.add('name: "${field.name}"');

    if (field.type.endsWith('?')) {
      jsonKeyParams.add('includeIfNull: false');
    }

    return '@JsonKey(${jsonKeyParams.join(', ')})';
  }

  String _generateToString(List<DartField> fields) {
    return fields.where((field) => !_shouldSkipField(field))
        .map((field) {
      final camelCaseName = ReCase(field.name).camelCase;
      return '$camelCaseName: \$$camelCaseName';
    }).join(', ');
  }

  bool _shouldSkipField(DartField field) {
    return field.attributes.contains('serde(skip_serializing)');
  }
}

class NetworkClassVisitor implements ClassVisitor {
  @override
  String visit(DartClass dartClass) {
    final className = dartClass.name;
    final baseClass = _determineBaseClass(className);
    final fields = _generateFields(dartClass.fields);
    final constructor = _generateNetworkConstructor(className, baseClass, dartClass.fields);
    final toJsonMethod = _generateNetworkToJsonMethod(className, baseClass);

    return '''
@JsonSerializable()
class $className extends $baseClass {
  $fields

  $constructor

  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);
  $toJsonMethod

  @override
  String toString() {
    return '$className{${_generateToString(dartClass.fields)}}';
  }
}
''';
  }

  String _generateFields(List<DartField> fields) {
    return fields.where((field) => !_shouldSkipField(field))
        .map((field) {
      final jsonKey = _generateJsonKey(field);
      final camelCaseName = ReCase(field.name).camelCase;
      return '$jsonKey\n  final ${field.type} $camelCaseName;';
    }).join('\n  ');
  }

  String _generateNetworkConstructor(String className, String baseClass, List<DartField> fields) {
    final params = fields.where((field) => !_shouldSkipField(field))
        .map((field) {
      final camelCaseName = ReCase(field.name).camelCase;
      return 'required this.$camelCaseName,';
    }).join('\n    ');

    final hasParams = params.isNotEmpty;

    switch (baseClass) {
      case 'RequestPacket':
        return hasParams
            ? '$className({$params}) : super(packetType: "$className");'
            : '$className() : super(packetType: "$className");';
      case 'ResponseData':
      case 'EventData':
        return hasParams
            ? 'const $className({$params}) : super();'
            : 'const $className() : super();';
      default:
        return hasParams ? '$className({$params});' : '$className();';
    }
  }

  String _generateNetworkToJsonMethod(String className, String baseClass) {
    return '''
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _\$${className}ToJson(this);
    json.addAll(super.toJson());
    return json;
  }''';
  }

  String _generateJsonKey(DartField field) {
    final jsonKeyParams = <String>[];
    jsonKeyParams.add('name: "${field.name}"');

    if (field.type.endsWith('?')) {
      jsonKeyParams.add('includeIfNull: false');
    }

    return '@JsonKey(${jsonKeyParams.join(', ')})';
  }

  String _generateToString(List<DartField> fields) {
    return fields.where((field) => !_shouldSkipField(field))
        .map((field) {
      final camelCaseName = ReCase(field.name).camelCase;
      return '$camelCaseName: \$$camelCaseName';
    }).join(', ');
  }

  String _determineBaseClass(String className) {
    if (className.startsWith('Req')) return 'RequestPacket';
    if (className.startsWith('Res')) return 'ResponseData';
    if (className.startsWith('Evt')) return 'EventData';
    return 'Object';
  }

  bool _shouldSkipField(DartField field) {
    return field.attributes.contains('serde(skip_serializing)');
  }
}

class RelationClassVisitor implements ClassVisitor {
  @override
  String visit(DartClass dartClass) {
    final className = dartClass.name;
    final fields = _generateFields(dartClass.fields);
    final constructor = _generateRelationConstructor(className, dartClass.fields);
    final toJsonMethod = _generateToJsonMethod(className);

    return '''
@JsonSerializable()
class $className extends Relation {
  $fields

  $constructor

  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);
  $toJsonMethod

  @override
  String toString() {
    return '$className{${_generateToString(dartClass.fields)}}';
  }
}
''';
  }

  String _generateFields(List<DartField> fields) {
    return fields.where((field) => !['input', 'output', 'id'].contains(field.name) && !_shouldSkipField(field))
        .map((field) {
      final jsonKey = _generateJsonKey(field);
      final camelCaseName = ReCase(field.name).camelCase;
      return '$jsonKey\n  final ${field.type} $camelCaseName;';
    }).join('\n  ');
  }

  String _generateRelationConstructor(String className, List<DartField> fields) {
    final params = fields.where((field) => !['input', 'output', 'id'].contains(field.name) && !_shouldSkipField(field))
        .map((field) {
      final camelCaseName = ReCase(field.name).camelCase;
      return 'required this.$camelCaseName,';
    }).join('\n    ');
    const superParams = 'required String input, required String output, required String id';
    return '$className({$params $superParams}) : super(input: input, output: output, id: id);';
  }

  String _generateToJsonMethod(String className) {
    return '''
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _\$${className}ToJson(this);
    json.addAll(super.toJson());
    return json;
  }''';
  }

  String _generateJsonKey(DartField field) {
    final jsonKeyParams = <String>[];
    jsonKeyParams.add('name: "${field.name}"');

    if (field.type.endsWith('?')) {
      jsonKeyParams.add('includeIfNull: false');
    }

    return '@JsonKey(${jsonKeyParams.join(', ')})';
  }

  String _generateToString(List<DartField> fields) {
    final regularFields = fields.where((field) => !['input', 'output', 'id'].contains(field.name) && !_shouldSkipField(field))
        .map((field) {
      final camelCaseName = ReCase(field.name).camelCase;
      return '$camelCaseName: \$$camelCaseName';
    });

    final allFields = ['id: \$id', 'input: \$input', 'output: \$output', ...regularFields];
    return allFields.join(', ');
  }

  bool _shouldSkipField(DartField field) {
    return field.attributes.contains('serde(skip_serializing)');
  }
}

class RustToDartGenerator {
  static const Map<String, String> _rustToDartTypes = {
    'u8': 'int',
    'u16': 'int',
    'u32': 'int',
    'u64': 'int',
    'i16': 'int',
    'i32': 'int',
    'i64': 'int',
    'bool': 'bool',
    'String': 'String',
    'Option<String>': 'String?',
    'Vec<String>': 'List<String>',
    'RecordId': 'String',
    'Datetime': 'DateTime',
    'Message': 'Message',
    'Relation': 'Relation',
    'Server': 'Server',
    'Permission': 'Permission',
    'Role': 'Role',
    'Channel': 'Channel',
    'User': 'User',
  };

  final String _rustDir;
  final String _dartOutputPath;
  final String _dartModelOutputPath;
  final Map<String, ClassVisitor> _visitors;

  RustToDartGenerator(String rustDir, String dartOutputPath, String dartModelOutputPath)
      : _rustDir = path.absolute(rustDir),
        _dartOutputPath = path.absolute(dartOutputPath),
        _dartModelOutputPath = path.absolute(dartModelOutputPath),
        _visitors = {
          'default': DefaultClassVisitor(),
          'network': NetworkClassVisitor(),
          'relation': RelationClassVisitor(),
        };

  Future<void> generate() async {
    await _generateNetworkClasses();
    await _generateModelClasses();
  }

  Future<void> _generateNetworkClasses() async {
    final requests = await _parseRustFile('network/requests.rs');
    final responses = await _parseRustFile('network/responses.rs');
    final events = await _parseRustFile('network/events.rs');

    final allClasses = [...requests, ...responses, ...events];

    final output = StringBuffer();
    output.writeln(_generateHeader());
    output.writeln(_generateImports());
    output.writeln(_generateEnums(requests, responses, events));
    output.writeln(_generateBaseClasses());
    output.writeln(_generateDartClasses(allClasses, 'network'));
    output.writeln(_generatePacketFactory(responses));

    await File(_dartOutputPath).writeAsString(output.toString());
    print('Generated Dart network classes have been written to $_dartOutputPath');
  }

  Future<void> _generateModelClasses() async {
    final models = await _parseRustFile('models.rs');

    final output = StringBuffer();
    output.writeln(_generateHeader());
    output.writeln(_generateModelImports());
    output.writeln(_generateDartClasses(models, 'default'));

    await File(_dartModelOutputPath).writeAsString(output.toString());
    print('Generated Dart model classes have been written to $_dartModelOutputPath');
  }

  String _generateHeader() {
    return '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: unused_element, unused_field, unused_import, unnecessary_this, prefer_const_constructors\n\n';
  }

  String _generateImports() {
    return '''
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'package:collection/collection.dart';

part '${path.basename(_dartOutputPath).replaceFirst('.dart', '.g.dart')}';

''';
  }

  String _generateModelImports() {
    return '''
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';

part '${path.basename(_dartModelOutputPath).replaceFirst('.dart', '.g.dart')}';

''';
  }

  String _generateEnums(List<DartClass> requests, List<DartClass> responses, List<DartClass> events) {
    final allNames = [...requests, ...responses, ...events].map((s) => s.name).toList();
    return '@JsonEnum()\nenum PacketType {\n  '
        '${allNames.map((name) => '@JsonValue("$name")\n  ${ReCase(name).camelCase},').join('\n  ')}\n'
        '}\n\n';
  }

  String _generateBaseClasses() {
    return '''
@JsonSerializable()
class RequestPacket {
  @JsonKey(name: "type")
  final String packetType;

  RequestPacket({required this.packetType});

  factory RequestPacket.fromJson(Map<String, dynamic> json) => _\$RequestPacketFromJson(json);
  Map<String, dynamic> toJson() => _\$RequestPacketToJson(this);
}

@JsonSerializable()
class ResponseData {
  const ResponseData();

  factory ResponseData.fromJson(Map<String, dynamic> json) => _\$ResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _\$ResponseDataToJson(this);
}

@JsonSerializable()
class EventData {
  const EventData();

  factory EventData.fromJson(Map<String, dynamic> json) => _\$EventDataFromJson(json);
  Map<String, dynamic> toJson() => _\$EventDataToJson(this);
}

class PacketError {
  final String message;

  PacketError(this.message);

  factory PacketError.fromJson(Map<String, dynamic> json) {
    return PacketError(json['message'] as String);
  }

  Map<String, dynamic> toJson() => {'message': message};
  
  @override
  String toString() {
    return 'PacketError{message: \$message}';
  }
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
    return 'ApiResponse{requestId: \$requestId, data: \${data?.toString()}, error: \$error, type: \$type}';
  }
}
''';
  }

  String _generatePacketFactory(List<DartClass> structs) {
    return '''
class PacketFactory {
  static final Map<Type, ApiResponse<ResponseData> Function(int?, String, PacketError?)> _creators = {
    ${structs.where((struct) => struct.name.startsWith('Res')).map((struct) => '''
    ${struct.name}: (requestId, type, error) => ApiResponse<${struct.name}>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),''').join('\n    ')}
  };
  
  static ApiResponse<ResponseData> createErrorResponse(Type type, int? requestId, String responseType, PacketError? error) {
    final creator = _creators[type];
    if (creator == null) {
      throw Exception('Unknown packet type: \$type');
    }
    return creator(requestId, responseType, error);
  }

  static Type? getTypeFromString(String typeString) {
    return _creators.keys.firstWhereOrNull(
      (type) => type.toString() == typeString,
    );
  }
}''';
  }

  String _generateDartClasses(List<DartClass> classes, String visitorKey) {
    return classes.map((dartClass) {
      final visitor = _getVisitor(dartClass, visitorKey);
      return visitor.visit(dartClass);
    }).join('\n\n');
  }

  ClassVisitor _getVisitor(DartClass dartClass, String defaultVisitorKey) {
    if (dartClass.name.endsWith('Relation') && dartClass.name != 'Relation') {
      return _visitors['relation']!;
    }
    return _visitors[defaultVisitorKey] ?? _visitors['default']!;
  }

  Future<List<DartClass>> _parseRustFile(String filename) async {
    final file = File(path.join(_rustDir, filename));
    if (!await file.exists()) {
      print('Warning: File not found: ${file.path}');
      return [];
    }
    final content = await file.readAsString();
    return _parseRustStructs(content);
  }

  List<DartClass> _parseRustStructs(String content) {
    final structRegex = RegExp(r'#\[derive\(.*?\)\]\s*(?:#\[.*?\]\s*)*pub struct (\w+) \{([\s\S]*?)\}', multiLine: true);
    final fieldRegex = RegExp(r'(?:#\[(.*?)\])?\s*pub (r#)?(\w+): ([\w<>]+)', multiLine: true);

    return structRegex.allMatches(content).map((match) {
      final name = match.group(1)!;
      final fields = fieldRegex.allMatches(match.group(2)!).map((fieldMatch) {
        final attributes = fieldMatch.group(1)?.split(',').map((attr) => attr.trim()).toList() ?? [];
        final isRawIdentifier = fieldMatch.group(2) != null;
        final fieldName = fieldMatch.group(3)!;
        final fieldType = fieldMatch.group(4)!;

        return DartField(
          name: _processFieldName(fieldName, isRawIdentifier, attributes),
          type: _resolveDartType(fieldType),
          attributes: attributes,
        );
      }).toList();
      return DartClass(name: name, fields: fields);
    }).toList();
  }

  String _processFieldName(String fieldName, bool isRawIdentifier, List<String> attributes) {
    if (isRawIdentifier) {
      fieldName = fieldName.startsWith('r#') ? fieldName.substring(2) : fieldName;
    }

    // Check for serde rename attribute
    final renameAttr = attributes.firstWhere(
          (attr) => attr.startsWith('serde(rename'),
      orElse: () => '',
    );

    if (renameAttr.isNotEmpty) {
      final renameRegex = RegExp(r'rename\s*(?:\(\s*(?:serialize|deserialize)\s*=\s*"(\w+)"\s*\)|\s*=\s*"(\w+)")');
      final renameMatch = renameRegex.firstMatch(renameAttr);
      if (renameMatch != null) {
        // Use the first non-null group (either serialize/deserialize specific or simple rename)
        return renameMatch.group(1) ?? renameMatch.group(2)!;
      }
    }

    return fieldName;
  }

  String _resolveDartType(String rustType) {
    if (rustType.startsWith('Option<')) {
      final innerType = rustType.substring(7, rustType.length - 1);
      return '${_resolveDartType(innerType)}?';
    }

    // Check if we are mapping Vec
    if(_rustToDartTypes[rustType] != null) {
      return _rustToDartTypes[rustType]!;
    }

    if (rustType.startsWith('Vec<')) {
      final innerType = rustType.substring(4, rustType.length - 1);
      return 'List<${_resolveDartType(innerType)}>';
    }
    return _rustToDartTypes[rustType] ?? rustType;
  }
}

void main() async {
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final rustDir = path.normalize(path.join(scriptDir, '..', 'talk-server', 'src'));
  final dartOutputPath = path.join(scriptDir, 'lib', 'core', 'network', 'api_types.dart');
  final dartModelOutputPath = path.join(scriptDir, 'lib', 'core', 'models', 'models.dart');

  final generator = RustToDartGenerator(rustDir, dartOutputPath, dartModelOutputPath);

  try {
    await generator.generate();
    print('Code generation completed successfully.');

    // Print out generated classes for debugging
    final apiTypesContent = await File(dartOutputPath).readAsString();
    print('Generated api_types.dart content:');
    print(apiTypesContent);

    final modelsContent = await File(dartModelOutputPath).readAsString();
    print('Generated models.dart content:');
    print(modelsContent);
  } catch (e, stackTrace) {
    print('Error during code generation: $e');
    print('Stack trace: $stackTrace');
  }
}