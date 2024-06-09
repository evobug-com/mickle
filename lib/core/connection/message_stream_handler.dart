import 'dart:convert';
import 'dart:typed_data';

import 'package:logging/logging.dart';

final _logger = Logger('MessageStreamHandler');

/// The `MessageStreamHandler` class handles incoming data, buffering incomplete messages
/// and processing complete messages. It's useful for dealing with data that arrives in parts,
/// like network communication or file streaming.
///
/// Example usage:
///
/// ```dart
/// void main() {
///   // Function to process complete messages
///   Future<void> processMessage(Uint8List data) async {
///     print('Received message: ${String.fromCharCodes(data)}');
///   }
///
///   // Create the handler with the processing function
///   final buffer = MessageStreamHandler(processMessage);
///
///   // Simulate receiving data in parts
///   buffer.onData(Uint8List.fromList([0, 0, 0, 5])); // Length prefix (5 bytes)
///   buffer.onData(Uint8List.fromList([72, 101, 108, 108, 111])); // "Hello"
///   buffer.onData(Uint8List.fromList([0, 0, 0, 5, 87, 111, 114, 108, 100])); // "World"
///
///   // Output:
///   // Received message: Hello
///   // Received message: World
/// }
/// ```
///
/// This class ensures that incomplete data is buffered until a complete message is
/// available, preventing the processing of partial data and ensuring efficient
/// and correct handling of incoming data.
class MessageStreamHandler {
  final BytesBuilder _bytesBuilder = BytesBuilder();
  int? _expectedLength;
  Future<void>? _processingFuture;
  final List<Future<void> Function()> _processingBuffer = [];
  final Future<void> Function(Uint8List data) _process;

  /// Constructs an `MessageStreamHandler` with a specified processing function.
  ///
  /// The `process` function will be called whenever a complete message is available
  /// for processing.
  MessageStreamHandler(this._process);

  /// Handles incoming data by adding it to the buffer and processing complete messages.
  ///
  /// This method should be called whenever new data is received. It buffers the data,
  /// determines the length of messages based on a 4-byte length prefix, and processes
  /// complete messages asynchronously.
  void onData(Uint8List data) {
    try {
      _bytesBuilder.add(data);

      // If the expected length is not set and there are enough bytes, determine the message length.
      if (_expectedLength == null && _bytesBuilder.length >= 4) {
        _setExpectedLength();
      }

      // Process messages as long as there are enough bytes in the buffer.
      while (_expectedLength != null && _bytesBuilder.length >= _expectedLength!) {
        _processCompleteMessage();
      }
    } catch (e, stackTrace) {
      _logger.severe('Error in onData: $e', [e, stackTrace]);
      _resetBuffer();
    }
  }

  /// Sets the expected length of the incoming message based on the first 4 bytes in the buffer.
  void _setExpectedLength() {
    final lengthBytes = _bytesBuilder.toBytes().sublist(0, 4);
    final restBytes = _bytesBuilder.toBytes().sublist(4);
    _expectedLength = ByteData.sublistView(lengthBytes).getUint32(0, Endian.big);
    _bytesBuilder.clear();
    _bytesBuilder.add(restBytes);
  }

  /// Processes a complete message if enough bytes are available in the buffer.
  void _processCompleteMessage() {
    if (_expectedLength == null) return;

    final completeMessage = _bytesBuilder.toBytes().sublist(0, _expectedLength!);
    _scheduleProcessing(Uint8List.fromList(completeMessage));
    _resetBuffer();
  }

  /// Schedules the processing of a message, ensuring only one message is processed at a time.
  ///
  /// If another message is already being processed, the current message is added to the
  /// processing buffer to be handled later.
  void _scheduleProcessing(Uint8List message) {
    if (_processingFuture != null) {
      _processingBuffer.add(() => _safeProcess(message));
    } else {
      _processingFuture = _safeProcess(message);
    }
  }

  /// Safely processes a message, handling errors and ensuring subsequent processing.
  ///
  /// This method wraps the processing function in a try-catch block to handle any
  /// errors that might occur during processing. It also ensures that the next message
  /// in the buffer is processed after the current message is done.
  Future<void> _safeProcess(Uint8List message) async {
    try {
      await _process(message);
    } catch (e, stackTrace) {
      _logger.severe('Error in _process: $e', [e, stackTrace]);
    } finally {
      _processingFuture = null;
      _processNextInBuffer();
    }
  }

  /// Processes the next message in the buffer, if any.
  ///
  /// This method is called after the current message has been processed to ensure that
  /// any pending messages are handled in a FIFO (first-in, first-out) manner.
  void _processNextInBuffer() {
    if (_processingBuffer.isNotEmpty) {
      _processingFuture = _processingBuffer.removeAt(0)();
    }
  }

  /// Resets the buffer and prepares it for the next message.
  ///
  /// This method clears the buffer and re-adds any remaining bytes that were not part
  /// of the processed message, setting up the buffer to receive the next incoming message.
  void _resetBuffer() {
    if (_expectedLength == null) return;

    final remaining = _bytesBuilder.toBytes().sublist(_expectedLength!);
    _bytesBuilder.clear();
    _bytesBuilder.add(remaining);
    _expectedLength = null;

    if (_bytesBuilder.length >= 4) {
      _setExpectedLength();
      while (_expectedLength != null && _bytesBuilder.length >= _expectedLength!) {
        _processCompleteMessage();
      }
    }
  }

  BytesBuilder get bytesBuilder => _bytesBuilder;

  // For UDP
  final Map<int, String> _receivedChunks = {};
  int? _totalChunks;

  void onUDPData(Uint8List data) {
    try {
      _bytesBuilder.add(data);

      // Check for metadata (sequential order and total of fragments) kompletní
      if (_totalChunks == null && _bytesBuilder.length >= 4 + 4) {
        _setUDPMetadata();
      }

      // If we have metadata done, process the data
      while (_totalChunks != null && _bytesBuilder.length >= 4 + 4) {
        _processUDPData();
      }
    } catch (e, stackTrace) {
      _logger.severe('Error in onUDPData: $e', [e, stackTrace]);
      _resetBuffer();
    }
  }

  void _setUDPMetadata() {
    final metadataBytes = _bytesBuilder.toBytes().sublist(0, 8);
    final sequenceNumber = ByteData.sublistView(metadataBytes, 0, 4).getUint32(0, Endian.big);
    _totalChunks = ByteData.sublistView(metadataBytes, 4, 8).getUint32(0, Endian.big);

    _bytesBuilder.clear();
    _bytesBuilder.add(metadataBytes.sublist(8));

    _logger.info('Metadata set: sequenceNumber=$sequenceNumber, totalChunks=$_totalChunks');
  }

  void _processUDPData() {
    final data = _bytesBuilder.toBytes();
    final sequenceNumber = ByteData.sublistView(data, 0, 4).getUint32(0, Endian.big);
    final chunkData = data.sublist(8);

    _receivedChunks[sequenceNumber] = utf8.decode(chunkData);

    // Check if we have all fragments
    if (_totalChunks != null && _receivedChunks.length == _totalChunks) {
      final orderedChunks = List.generate(_totalChunks!, (index) => _receivedChunks[index]!);
      final completeMessage = Uint8List.fromList(utf8.encode(orderedChunks.join('')));
      _scheduleProcessing(completeMessage);
      _receivedChunks.clear();
      _totalChunks = null;
    }

    _bytesBuilder.clear();
  }
}