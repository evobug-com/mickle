import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

import 'package:talk/core/connection/message_stream_handler.dart';

void main() {
  group('MessageStreamHandler', () {
    late List<Uint8List> processedMessages;
    late MessageStreamHandler handler;

    setUp(() {
      processedMessages = [];

      handler = MessageStreamHandler((Uint8List data) async {
        processedMessages.add(data);
      });
    });

    test('processes complete message', () async {
      final data = Uint8List.fromList([0, 0, 0, 5, 72, 101, 108, 108, 111]); // "Hello"
      handler.onData(data);

      // Allow the handler to process the message
      await Future.delayed(Duration.zero);

      expect(processedMessages, [Uint8List.fromList([72, 101, 108, 108, 111])]);
    });

    test('buffers incomplete message and processes when complete', () async {
      final part1 = Uint8List.fromList([0, 0, 0, 5]); // Length prefix (5 bytes)
      final part2 = Uint8List.fromList([72, 101]); // "He"
      final part3 = Uint8List.fromList([108, 108, 111]); // "llo"

      handler.onData(part1);
      handler.onData(part2);
      handler.onData(part3);

      // Allow the handler to process the message
      await Future.delayed(Duration.zero);

      expect(processedMessages, [Uint8List.fromList([72, 101, 108, 108, 111])]);
    });

    test('handles multiple messages in one data chunk', () async {
      final data = Uint8List.fromList([
        0, 0, 0, 5, 72, 101, 108, 108, 111, // "Hello"
        0, 0, 0, 5, 87, 111, 114, 108, 100  // "World"
      ]);

      handler.onData(data);

      // Allow the handler to process the message
      await Future.delayed(Duration.zero);

      expect(processedMessages, [
        Uint8List.fromList([72, 101, 108, 108, 111]),
        Uint8List.fromList([87, 111, 114, 108, 100])
      ]);
    });

    test('processes messages one at a time', () async {
      final data1 = Uint8List.fromList([0, 0, 0, 5, 72, 101, 108, 108, 111]); // "Hello"
      final data2 = Uint8List.fromList([0, 0, 0, 5, 87, 111, 114, 108, 100]); // "World"

      handler.onData(data1);
      await Future.delayed(Duration.zero);

      expect(processedMessages, [Uint8List.fromList([72, 101, 108, 108, 111])]);

      handler.onData(data2);
      await Future.delayed(Duration.zero);

      expect(processedMessages, [
        Uint8List.fromList([72, 101, 108, 108, 111]),
        Uint8List.fromList([87, 111, 114, 108, 100])
      ]);
    });

    test('handles errors in processing function gracefully', () async {
      handler = MessageStreamHandler((Uint8List data) async {
        processedMessages.add(data);
        throw Exception('Processing error');
      });

      final data = Uint8List.fromList([0, 0, 0, 5, 72, 101, 108, 108, 111]); // "Hello"
      handler.onData(data);

      await Future.delayed(Duration.zero);

      expect(processedMessages, [Uint8List.fromList([72, 101, 108, 108, 111])]);
    });

    test('resets buffer correctly after processing', () async {
      final data1 = Uint8List.fromList([0, 0, 0, 5, 72, 101, 108, 108, 111]); // "Hello"
      final data2 = Uint8List.fromList([0, 0, 0, 5, 87, 111, 114, 108, 100]); // "World"

      handler.onData(data1);
      handler.onData(data2);

      expect(processedMessages, [Uint8List.fromList([72, 101, 108, 108, 111])]);

      // Check that buffer is reset and ready for next message
      expect(handler.bytesBuilder.length, 0);
    });
  });
}
