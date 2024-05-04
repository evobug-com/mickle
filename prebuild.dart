import 'dart:async';
import 'dart:io';

String snakeToCamel(String snake) {
  final parts = snake.split('_');
  return parts[0] + parts.sublist(1).map((part) => part[0].toUpperCase() + part.substring(1)).join('');
}

String constructSerializeFunction(String className, List<String> fields) {

  // Classes are mapped to MapWKey("ClassName", () { ... })
  // Arrays are mapped to ArrayWKey("ArrayName", () { ... })
  // Fields are mapped to addTypeWKey("fieldName", fieldName)

  // Fields prepend request_id: u16
  // fields.insert(0, 'int requestId');

  return '''
  serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("$className", () {
      ${fields.map((field) {
    final parts = field.split(' ');
    final fieldName = parts[1];
    String fieldType = parts[0];

    // if array (List) then call addArrayWKey
    if(fieldType.startsWith('List')) {
      return 'builder.addArrayWKey("${snakeToCamel(fieldName)}", () { ${fieldName}.forEach((item) { builder.add${fieldType[5].toUpperCase()}${fieldType.substring(6)}(item); }); });';
    }

    // if String or Int then call addTypeWKey
    if (fieldType.startsWith("String") || fieldType.startsWith("int")) {
      if(fieldType.endsWith("?")) {
        fieldType = fieldType.substring(0, fieldType.length - 1);
        return 'if($fieldName != null) { builder.add${fieldType[0].toUpperCase()}${fieldType.substring(1)}WKey("${snakeToCamel(fieldName)}", $fieldName!); } else { builder.addNullWKey("${snakeToCamel(fieldName)}"); }';
      }

      return 'builder.add${fieldType[0].toUpperCase()}${fieldType.substring(1)}WKey("${snakeToCamel(fieldName)}", $fieldName);';
    }

    // Otherwise call addMapWKey
    return 'builder.addMapWKey("${snakeToCamel(fieldName)}", () { $fieldName.serialize(); });';
  }).join('\n      ')}
    });
    
    return builder.finish(); 
  } 
''';
}


final rustToDartTypes = {
  'u16': 'int',
  'u32': 'int',
  'u64': 'int',
  'i16': 'int',
  'i32': 'int',
  'i64': 'int',
  'bool': 'bool',
  'String': 'String',
  'RecordId': 'String',
  'Message': 'models.Message',
  'Relation': 'models.Relation',
  'Server': 'models.Server',
  'Permission': 'models.Permission',
  'Role': 'models.Role',
  'Channel': 'models.Channel',
  'User': 'models.User',
};

String resolveRuntimeType(String type, {String? prefix, String? suffix}) {
  if (type.startsWith('Option<')) {
    return resolveRuntimeType(type.substring(7, type.length - 1), suffix: '?', prefix: prefix);
  }
  if (type.startsWith('Vec<')) {
    return '${prefix ?? ''}List<${resolveRuntimeType(type.substring(4, type.length - 1))}>${suffix ?? ''}';
  }

  if(!rustToDartTypes.containsKey(type)) {
    type = "dynamic";
  }

  return '${prefix ?? ''}${rustToDartTypes[type] ?? type}${suffix ?? ''}';
}


String generateRequest() {
  print('Generating request');

  // Read content of file ../talk-server/src/network/packet.rs
  // Parse the PacketRequest enum
  // Generate a Request class for each variant with serialize method
  // Return the generated code

  final packetFile = File('../talk-server/src/network/packet.rs');
  final packetContent = packetFile.readAsStringSync();

  // Regex to match the PacketRequest enum
  final packetRequestEnum = RegExp(r'pub enum PacketRequest {\s*(.*)\s*}.*?pub enum PacketResponse {', dotAll: true).firstMatch(packetContent)?.group(1);
  if(packetRequestEnum == null) {
    // Throw an error that the PacketRequest enum was not found
    throw Exception('PacketRequest enum not found in packet.rs');
  }

  // Regex to match the variants of the PacketRequest enum
  final packetRequestVariants = RegExp(r'(\w+) {(.*?)}', dotAll: true).allMatches(packetRequestEnum);

  String generatedCode = "part of 'request.dart';\n\n";

  // Remap the fields to Dart types


  packetRequestVariants.forEach((match) {
    // Group 1: Class name, Group 2: Fields
    final className = match.group(1)!;
    print('Class Name: $className');

    // Fields are: field_name: field_type
    List<String> fields = match.group(2)!.split(',').map((field) => field.trim()).where((element) => element.isNotEmpty).toList();

    print ('Fields: $fields');
    // Remap the field types and convert to camelCase
    fields = fields.map((field) {
      final parts = field.split(':').map((part) => part.trim()).toList();
      final fieldName = parts[0];
      final fieldType = resolveRuntimeType(parts[1]);
      return '$fieldType ${snakeToCamel(fieldName)}';
    }).toList();

    // Generate the Request class
    generatedCode += '''
class $className extends Request {

  ${fields.isNotEmpty ? '${fields.join(';\n  ')};' : ''}
  
  $className(${
    fields.isNotEmpty ? '''{${fields.map((e)
    {
      final parts = e.split(' ');
      final fieldType = parts[0];
      final fieldName = parts[1];
      final isOptional = fieldType.endsWith('?');
      // If not optional, then add required keyword
      return '${isOptional ? '' : 'required'} this.$fieldName';

    }).join(', ')}}''' : ''
    });
  
  ${constructSerializeFunction(className, fields)}
}
''';
  });
  return generatedCode;
}

String generateResponse() {
  print('Generating response');
  // Read content of file ../talk-server/src/network/packet.rs
  // Parse the PacketResponse enum
  // Generate a Response class for each variant with fromReference method
  // Return the generated code

  final packetFile = File('../talk-server/src/network/packet.rs');
  final packetContent = packetFile.readAsStringSync();

  // Regex to match the PacketResponse enum
  final packetResponseEnum = RegExp(r'pub enum PacketResponse {\s*(.*)\s*}.*?pub enum Packet', dotAll: true).firstMatch(packetContent)?.group(1);

  if(packetResponseEnum == null) {
    // Throw an error that the PacketResponse enum was not found
    throw Exception('PacketResponse enum not found in packet.rs');
  }

  // Regex to match the variants of the PacketResponse enum
  final packetResponseVariants = RegExp(r'(\w+) {(.*?)}', dotAll: true).allMatches(packetResponseEnum);

  String generatedCode = "part of 'response.dart';\n\n";

  packetResponseVariants.forEach((match) {
    // Group 1: Class name, Group 2: Fields
    final className = match.group(1)!;

    // Fields are: field_name: field_type
    List<String> fields = match.group(2)!.split(',').map((field) => field.trim()).where((element) => element.isNotEmpty && !element.startsWith("//")).toList();
    print('Class Name: $className');

    print ('Fields: $fields');
    // Remap the field types and convert to camelCase
    fields = fields.map((field) {
      final parts = field.split(':').map((part) => part.trim()).toList();
      final fieldName = parts[0];
      String fieldType = resolveRuntimeType(parts[1]);
      return '$fieldType ${snakeToCamel(fieldName)}';
    }).toList();

    // Generate the Response class
    generatedCode += '''
class $className {

  ${fields.isNotEmpty ? '''${fields.map((element) {
      final parts = element.split(' ');
      String fieldType = parts[0];
      final fieldName = parts[1];
      if(!fieldType.endsWith("?")) {
        fieldType = "late $fieldType";
      }
      return '$fieldType $fieldName';
    }).join(';\n  ')};''' : ''}
  
  $className();
  
  factory $className.fromReference(flex_buffers.Reference data) {
    return $className()
      ${fields.isNotEmpty ? '''${fields.map((e)
    {
      final parts = e.split(' ');
      final fieldType = parts[0].replaceAll("?", "");
      final fieldName = parts[1];

      // if array (List) then call vectorIterable
      // If the inner type is a custom type, then call fromReference on the custom type
      if(fieldType.startsWith('List')) {
        final innerType = fieldType.substring(5, fieldType.length - 1);
        if (innerType != "int" && innerType != "String" && innerType != "bool" && innerType != "double") {
          return '..$fieldName = data["${snakeToCamel(fieldName)}"].vectorIterable.map((item) => $innerType.fromReference(item)).toList()';
        }
        return '..$fieldName = data["${snakeToCamel(fieldName)}"].vectorIterable';
      }

      // If type is a custom type, then call fromReference on the custom type
      if (fieldType != "int" && fieldType != "String" && fieldType != "bool" && fieldType != "double") {
        return '..$fieldName = data["${snakeToCamel(fieldName)}"].isNull ? null : $fieldType.fromReference(data["${snakeToCamel(fieldName)}"])';
      }

      return '..$fieldName = data["${snakeToCamel(fieldName)}"].${fieldType[0].toLowerCase()}${fieldType.substring(1)}Value${parts[0].endsWith("?") ? '' : '!'}';
    }).join('\n      ')};''' : ';'}
  }
}
''';
  });
  return generatedCode;

}

String generateModels() {
  print ('Generating models');

  // Read content of file ../talk-server/src/models.rs
  // Parse each struct
  // Generate a Model class for each variant
  // Return the generated code

  final modelsFile = File('../talk-server/src/models.rs');
  final modelsContent = modelsFile.readAsStringSync();

  // Regex to match the struct definitions
  final structDefinitions = RegExp(r'(\w+) {(.*?)}', dotAll: true).allMatches(modelsContent);
  if (structDefinitions.isEmpty) {
    // Throw an error that no struct definitions were found
    throw Exception('No struct definitions found in models.rs');
  }

  String generatedCode = "part of 'models.dart';\n\n";

  structDefinitions.forEach((match) {
    // Group 1: Struct name, Group 2: Fields
    final structName = match.group(1)!;
    print('Struct Name: $structName');

    // Fields are: field_name: field_type
    // Split ,
    List<String> fields = match.group(2)!.split(',').map((field) {
      // Replace 'pub ' with empty string and trim
      return field.replaceAll('pub ', '').trim();
    }).where((element) {
      // Remove empty fields
      // Remove comments

      // If #[serde(skip_serializing)] then skip
      if (element.contains("skip_serializing")) {
        return false;
      }

      return element.isNotEmpty && !element.startsWith('//');
    }).map((element) {
      // if #[serde(rename = "value")] then rename
      if (element.contains("serde(rename")) {
        // Extract new name via regex
        String newName = RegExp(r'serde\(rename.*?"(.*?)"').firstMatch(element)?.group(1) ?? '';
        // Remove #[serde(rename = "value")]
        element = element.replaceAll(RegExp(r'#\[.*\]'), '');
        // Trim new line
        element = element.trim();
        // Split by : and return with new name
        final parts = element.split(':').map((part) => part.trim()).toList();
        return '$newName: ${parts[1]}';
      }
      return element;
    }).toList();

    print('Struct Fields: ${fields}');

    // Remap the field types and convert to camelCase
    fields = fields.map((field) {
      final parts = field.split(':').map((part) => part.trim()).toList();
      final fieldName = parts[0];
      final fieldType = resolveRuntimeType(parts[1]);
      return '$fieldType ${snakeToCamel(fieldName)}';
    }).toList();

    print('Struct Remapped Fields: ${fields}');

    // Generate the Model class
    generatedCode += '''
class $structName extends ChangeNotifier {
  ${fields.join(';\n  ')};
  
  $structName({${fields.map((e)
    {
      final parts = e.split(' ');
      final fieldType = parts[0];
      final fieldName = parts[1];
      final isOptional = fieldType.endsWith('?');
      // If not optional, then add required keyword
      return '${isOptional ? '' : 'required'} this.$fieldName';

    }).join(', ')}});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory $structName.fromReference(flex_buffers.Reference data) {
    return $structName(
      ${fields.map((e)
    {
      final parts = e.split(' ');
      String fieldType = parts[0].replaceAll("?", "");
      if(fieldType == "dynamic") {
        fieldType = "String";
      }
      final fieldName = parts[1];
      // If not optional, then add required keyword
      return '${fieldName}: data["${snakeToCamel(fieldName)}"].${fieldType[0].toLowerCase()}${fieldType.substring(1)}Value${parts[0].endsWith("?") ? '' : '!'}';

    }).join(',\n      ')}
    );
  }
}
''';
  });

  return generatedCode;
}

void main() {
  final generatedCode = generateRequest();
  final output = File('lib/core/network/request.g.dart');
  output.writeAsStringSync(generatedCode);

  final generatedResponse = generateResponse();
  final responseOutput = File('lib/core/network/response.g.dart');
  responseOutput.writeAsStringSync(generatedResponse);

  final generatedModels = generateModels();
  final modelsOutput = File('lib/core/models/models.g.dart');
  modelsOutput.writeAsStringSync(generatedModels);
}