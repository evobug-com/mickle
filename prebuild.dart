import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

class RustToDartGenerator {
  static const Map<String, String> _rustToDartTypes = {
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

  RustToDartGenerator(String rustDir, String dartOutputPath, String dartModelOutputPath)
      : _rustDir = path.absolute(rustDir),
        _dartOutputPath = path.absolute(dartOutputPath),
        _dartModelOutputPath = path.absolute(dartModelOutputPath);

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
    output.writeln(_generateDartClasses(allClasses));

    await File(_dartOutputPath).writeAsString(output.toString());
    print('Generated Dart network classes have been written to $_dartOutputPath');
  }

  Future<void> _generateModelClasses() async {
    final models = await _parseRustFile('models.rs');

    final output = StringBuffer();
    output.writeln(_generateHeader());
    output.writeln(_generateModelImports());
    output.writeln(_generateDartClasses(models, finalFields: false));

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

  String _generateEnums(List<RustStruct> requests, List<RustStruct> responses, List<RustStruct> events) {
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
''';
  }

  String _generateDartClasses(List<RustStruct> structs, { bool finalFields = true }) {
    return structs.map((struct) => _generateDartClass(struct, finalFields: finalFields)).join('\n\n');
  }

  String _generateDartClass(RustStruct struct, { required bool finalFields }) {
    final className = struct.name;
    final isNetworkClass = _isNetworkClass(className);
    final baseClass = isNetworkClass ? _determineBaseClass(className) : null;

    final fields = struct.fields.where((field) => !_shouldSkipField(field)).map((field) {
      final dartType = _resolveDartType(field.type);
      final rustFieldName = field.name;
      final dartFieldName = ReCase(rustFieldName).camelCase;
      final jsonKey = _generateJsonKey(rustFieldName, dartFieldName, field.attributes, field.type);
      return '$jsonKey\n  ${finalFields ? 'final ' : ''}$dartType $dartFieldName;';
    }).join('\n  ');

    final constructorParams = struct.fields.where((field) => !_shouldSkipField(field)).map((field) {
      final dartFieldName = ReCase(field.name).camelCase;
      return 'required this.$dartFieldName,';
    }).join('\n    ');

    final extendsClause = baseClass != null ? ' extends $baseClass' : '';
    final changeNotifierMixin = baseClass == null ? ' with ChangeNotifier' : '';

    final constructor = _generateConstructor(className, baseClass, constructorParams);
    final toJsonMethod = _generateToJsonMethod(className, baseClass);

    return '''
@JsonSerializable()
class $className$extendsClause$changeNotifierMixin {
  $fields

  $constructor

  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);
  $toJsonMethod

  ${baseClass == null ? 'void notify() => notifyListeners();' : ''}
  
  @override
  String toString() {
    return '$className{${struct.fields.where((field) => !_shouldSkipField(field)).map((field) => '${ReCase(field.name).camelCase}: \$${ReCase(field.name).camelCase}').join(', ')}}';
  }
}
''';
  }

  String _generateConstructor(String className, String? baseClass, String constructorParams) {
    final hasParams = constructorParams.isNotEmpty;
    switch (baseClass) {
      case 'RequestPacket':
        return '''$className({
    ${hasParams ? constructorParams : ''}
  }) : super(packetType: "$className");''';
      case 'ResponseData':
      case 'EventData':
        return hasParams
            ? '''const $className({
    $constructorParams
  }) : super();'''
            : 'const $className() : super();';
      default:
        return hasParams ? '$className({$constructorParams});' : 'const $className();';
    }
  }

  String _generateToJsonMethod(String className, String? baseClass) {
    if (baseClass == null) {
      return 'Map<String, dynamic> toJson() => _\$${className}ToJson(this);';
    } else {
      return '''
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _\$${className}ToJson(this);
    json.addAll(super.toJson());
    return json;
  }''';
    }
  }

  String? _determineBaseClass(String className) {
    if (className.startsWith('Req')) return 'RequestPacket';
    if (className.startsWith('Res')) return 'ResponseData';
    if (className.startsWith('Evt')) return 'EventData';
    return null;
  }

  bool _isNetworkClass(String className) {
    return className.startsWith('Req') || className.startsWith('Res') || className.startsWith('Evt');
  }

  bool _shouldSkipField(RustField field) {
    return field.attributes.any((attr) => attr.trim() == 'serde(skip_serializing)');
  }

  String _generateJsonKey(String rustFieldName, String dartFieldName, List<String> attributes, String rustType) {
    final jsonKeyParams = <String>[];

    // Use the original Rust field name for the JsonKey
    jsonKeyParams.add('name: "$rustFieldName"');

    if (attributes.contains('serde(skip_serializing)')) {
      jsonKeyParams.add('includeIfNull: false');
    }

    return '@JsonKey(${jsonKeyParams.join(', ')})';
  }

  String _resolveDartType(String rustType) {
    if (rustType.startsWith('Option<')) {
      final innerType = rustType.substring(7, rustType.length - 1);
      return '${_resolveDartType(innerType)}?';
    }
    if (rustType.startsWith('Vec<')) {
      final innerType = rustType.substring(4, rustType.length - 1);
      return 'List<${_resolveDartType(innerType)}>';
    }
    return _rustToDartTypes[rustType] ?? rustType;
  }

  Future<List<RustStruct>> _parseRustFile(String filename) async {
    final file = File(path.join(_rustDir, filename));
    if (!await file.exists()) {
      print('Warning: File not found: ${file.path}');
      return [];
    }
    final content = await file.readAsString();
    return _parseRustStructs(content);
  }

  List<RustStruct> _parseRustStructs(String content) {
    final structRegex = RegExp(r'#\[derive\(.*?\)\]\s*(?:#\[.*?\]\s*)*pub struct (\w+) \{([\s\S]*?)\}', multiLine: true);
    final fieldRegex = RegExp(r'(?:#\[(.*?)\])?\s*pub (r#)?(\w+): ([\w<>]+)', multiLine: true);

    return structRegex.allMatches(content).map((match) {
      final name = match.group(1)!;
      final fields = fieldRegex.allMatches(match.group(2)!).map((fieldMatch) {
        final attributes = fieldMatch.group(1)?.split(',').map((attr) => attr.trim()).toList() ?? [];
        final isRawIdentifier = fieldMatch.group(2) != null;
        final fieldName = fieldMatch.group(3)!;
        final fieldType = fieldMatch.group(4)!;

        return RustField(
          name: _processFieldName(fieldName, isRawIdentifier, attributes),
          type: fieldType,
          attributes: attributes,
        );
      }).toList();
      return RustStruct(name: name, fields: fields);
    }).toList();
  }
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


class RustStruct {
  final String name;
  final List<RustField> fields;

  RustStruct({required this.name, required this.fields});
}

class RustField {
  final String name;
  final String type;
  final List<String> attributes;
  final bool isRawIdentifier;

  RustField({required this.name, required this.type, required this.attributes, this.isRawIdentifier = false});
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