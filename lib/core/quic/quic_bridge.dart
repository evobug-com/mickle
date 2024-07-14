import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import '../generated_bindings.dart';

// D:\2024\quiche
// cargo build --release --features ffi

// cd "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.40.33807\bin\Hostx64\x64"
// dumpbin /EXPORTS D:\2024\quiche\target\release\quiche.dll


// Load the Quiche library
ffi.DynamicLibrary _loadQuicheLibrary() {

  final librariesPath;
  if(kReleaseMode) {
    // Absolute linking
    librariesPath = p.join(Directory(Platform.resolvedExecutable).parent.path, 'data', 'flutter_assets', 'assets', 'libraries');
  } else {
    // Relative linking
    librariesPath = p.join(Directory.current.path, 'assets', 'libraries', 'debug');
  }

  print("librariesPath: $librariesPath");

  if (Platform.isWindows) {
    return ffi.DynamicLibrary.open(p.join(librariesPath, 'quiche.dll'));
  } else if (Platform.isMacOS) {
    return ffi.DynamicLibrary.open(p.join(librariesPath, 'libquiche.dylib'));
  } else if (Platform.isLinux || Platform.isAndroid) {
    return ffi.DynamicLibrary.open(p.join(librariesPath, 'libquiche.so'));
  } else if (Platform.isIOS) {
    return ffi.DynamicLibrary.process();
  }
  throw UnsupportedError('Unsupported platform for Quiche');
}

final ffi.DynamicLibrary quicheLib = _loadQuicheLibrary();
final NativeLibrary quiche = NativeLibrary(quicheLib);

typedef NativeQuiche_enable_debug_logging_Callback = ffi.Void Function(ffi.Pointer<ffi.Char> line, ffi.Pointer<ffi.Void> argp);
typedef NativeQuiche_enable_debug_logging = ffi.Int Function(ffi.Pointer<ffi.NativeFunction<NativeQuiche_enable_debug_logging_Callback>> cb, ffi.Pointer<ffi.Void> argp);
typedef DartQuiche_enable_debug_logging = int Function(ffi.Pointer<ffi.NativeFunction<NativeQuiche_enable_debug_logging_Callback>> cb, ffi.Pointer<ffi.Void> argp);
late final _quiche_enable_debug_loggingPtr =
quicheLib.lookup<ffi.NativeFunction<NativeQuiche_enable_debug_logging>>(
    'quiche_enable_debug_logging');
late final _quiche_enable_debug_logging = _quiche_enable_debug_loggingPtr
    .asFunction<DartQuiche_enable_debug_logging>();

const MAX_DATAGRAM_SIZE= 1350;

extension on ffi.Array<ffi.Char> {
  String toDartString() {
    final stringList = <int>[];
    var i = 0;
    while (this[i] != 0) {
      stringList.add(this[i]);
      i++;
    }
    return String.fromCharCodes(stringList);
  }

  void fillFromString(String str) {
    final codeUnits = str.codeUnits;
    for (var i = 0; i < codeUnits.length; i++) {
      this[i] = codeUnits[i];
    }
    this[codeUnits.length] = 0;
  }
}

class QuicheClientManager {
  static final QuicheClientManager _instance = QuicheClientManager._internal();

  factory QuicheClientManager() => _instance;

  QuicheClientManager._internal();

  late Isolate _networkIsolate;
  late SendPort _networkSendPort;
  final Map<int, QuicheClient> _clients = {};
  int _nextClientId = 0;
  bool initialized = false;

  Future<void> initialize() async {
    if (initialized) return;
    initialized = true;

    final receivePort = ReceivePort();
    _networkIsolate = await Isolate.spawn(_networkIsolateEntry, receivePort.sendPort);

    // Use a Completer to wait for the initial SendPort
    final sendPortCompleter = Completer<SendPort>();

    receivePort.listen((message) {
      if (!sendPortCompleter.isCompleted && message is SendPort) {
        // Handle the initial SendPort
        _networkSendPort = message;
        sendPortCompleter.complete(message);
      } else if (message is Map) {
        // Handle subsequent messages
        final clientId = message['clientId'];
        switch (message['type']) {
          case 'data':
            final data = message['data'];
            _clients[clientId]?._dataStreamController.add(data);
            break;
          case 'connected':
            _clients[clientId]?._connectionCompleter.complete();
            break;
          case 'error':
            if(!(_clients[clientId]?._connectionCompleter.isCompleted ?? false)) {
              final error = message['error'];
              _clients[clientId]?._connectionCompleter.completeError(error);
            } else {
              print('Error: ${message['error']}');
            }
            break;
        }
      }
    });

    // Wait for the SendPort to be received
    _networkSendPort = await sendPortCompleter.future;
  }

  Future<QuicheClient> createClient(String server, int port) async {
    final clientId = _nextClientId++;
    final client = QuicheClient._(clientId, _networkSendPort);
    _clients[clientId] = client;

    _networkSendPort.send({
      'type': 'create',
      'clientId': clientId,
      'server': server,
      'port': port,
    });

    await client._connectionCompleter.future;
    return client;
  }

  void _removeClient(int clientId) {
    _clients.remove(clientId);
    _networkSendPort.send({
      'type': 'close',
      'clientId': clientId,
    });
  }

  static void _networkIsolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    final Map<int, _QuicheConnection> connections = {};

    receivePort.listen((message) {
      if (message is Map) {
        final clientId = message['clientId'];
        switch (message['type']) {
          case 'create':
            final server = message['server'];
            final port = message['port'];
            _createConnection(
                connections, clientId, server, port, mainSendPort);
            break;
          case 'send':
            final data = message['data'] as Uint8List;
            _sendData(connections, clientId, data, mainSendPort);
            break;
          case 'close':
            _closeConnection(connections, clientId);
            connections.remove(clientId);
            break;
        }
      }
    });

    // Periodically process packets for all connections
    Timer.periodic(Duration(milliseconds: 10), (_) {
      for (var connection in connections.values) {
        _processPackets(connection, mainSendPort);
      }
    });
  }

  static void _createConnection(Map<int, _QuicheConnection> connections,
      int clientId,
      String server,
      int port,
      SendPort mainSendPort) async {
    try {
      final config = quiche.quiche_config_new(QUICHE_PROTOCOL_VERSION);
      if (config == ffi.nullptr) {
        throw Exception('Failed to create Quiche config');
      }

      final serverName = server.toNativeUtf8().cast<ffi.Char>();

      final random = Random.secure();
      final scid = Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
      final scidNative = scid.allocatePointer();

      final localAddr = calloc<sockaddr>();
      localAddr.ref.sa_family = AF_INET;
      localAddr.ref.sa_data.fillFromString(InternetAddress.loopbackIPv4.address);

      final peerAddr = calloc<sockaddr>();
      peerAddr.ref.sa_family = AF_INET;
      peerAddr.ref.sa_data.fillFromString((await InternetAddress.lookup(server)).first.address);

      final conn = quiche.quiche_connect(
        serverName,
        scidNative,
        scid.length,
        localAddr,
        ffi.sizeOf<sockaddr>(),
        peerAddr,
        ffi.sizeOf<sockaddr>(),
        config,
      );

      // malloc.free(serverName);
      // malloc.free(scidNative);
      // malloc.free(localAddr);
      // malloc.free(peerAddr);

      if (conn == ffi.nullptr) {
        throw Exception('Failed to create Quiche connection');
      }

      connections[clientId] = _QuicheConnection(conn, config, clientId, localAddr, peerAddr);
      mainSendPort.send({'type': 'connected', 'clientId': clientId});
    } catch (e) {
      mainSendPort.send(
          {'type': 'error', 'clientId': clientId, 'error': e.toString()});
    }
  }

  static void _sendData(Map<int, _QuicheConnection> connections,
      int clientId,
      Uint8List data,
      SendPort mainSendPort) {
    final connection = connections[clientId];
    if (connection == null) return;

    final dataPtr = malloc<ffi.Uint8>(data.length);
    dataPtr.asTypedList(data.length).setAll(0, data);

    final outInfo = malloc<quiche_send_info>();
    final toPtr = malloc<sockaddr_storage>();
    final fromPtr = malloc<sockaddr_storage>();
    outInfo.ref.to = toPtr.ref;
    outInfo.ref.to_len = ffi.sizeOf<sockaddr_storage>();
    outInfo.ref.from = fromPtr.ref;
    outInfo.ref.from_len = ffi.sizeOf<sockaddr_storage>();

    final written = quiche.quiche_conn_send(
        connection.conn, dataPtr, data.length, outInfo);

    malloc.free(dataPtr);
    malloc.free(outInfo);

    if (written < 0) {
      mainSendPort.send({
        'type': 'error',
        'clientId': clientId,
        'error': 'Failed to send data $written'
      });
    }
  }

  static void _processPackets(_QuicheConnection connection,
      SendPort mainSendPort) {
    final bufSize = 65535; // Max UDP packet size
    final buf = malloc<ffi.Uint8>(bufSize);

    final recvInfo = malloc<quiche_recv_info>();
    recvInfo.ref.from = connection.peerAddr;
    recvInfo.ref.from_len = ffi.sizeOf<sockaddr>();
    recvInfo.ref.to = connection.localAddr;
    recvInfo.ref.to_len = ffi.sizeOf<sockaddr>();

    final read = quiche.quiche_conn_recv(
        connection.conn, buf, bufSize, recvInfo);

    if (read > 0) {
      final data = Uint8List.fromList(buf.asTypedList(read));
      mainSendPort.send(
          {'type': 'data', 'clientId': connection.clientId, 'data': data});
    } else if (read < 0) {
      mainSendPort.send({
        'type': 'error',
        'clientId': connection.clientId,
        'error': 'Failed to receive data $read'
      });
    }

    malloc.free(buf);
    malloc.free(recvInfo);
  }

  static void _closeConnection(Map<int, _QuicheConnection> connections,
      int clientId) {
    final connection = connections[clientId];
    if (connection == null) return;

    quiche.quiche_conn_free(connection.conn);
    quiche.quiche_config_free(connection.config);
  }
}

class _QuicheConnection {
  final ffi.Pointer<quiche_conn> conn;
  final ffi.Pointer<quiche_config> config;
  final int clientId;
  final ffi.Pointer<sockaddr> localAddr;
  final ffi.Pointer<sockaddr> peerAddr;

  _QuicheConnection(this.conn, this.config, this.clientId, this.localAddr, this.peerAddr);
}

class QuicheClient {
  final int _id;
  final SendPort _networkSendPort;
  final StreamController<Uint8List> _dataStreamController = StreamController<Uint8List>.broadcast();
  final Completer<void> _connectionCompleter = Completer<void>();

  QuicheClient._(this._id, this._networkSendPort);

  Stream<Uint8List> get dataStream => _dataStreamController.stream;

  Future<void> get connected => _connectionCompleter.future;

  void send(Uint8List data) {
    _networkSendPort.send({
      'type': 'send',
      'clientId': _id,
      'data': data,
    });
  }

  void close() {
    QuicheClientManager()._removeClient(_id);
    _dataStreamController.close();
  }
}

// Helper extension
extension on Uint8List {
  ffi.Pointer<ffi.Uint8> allocatePointer() {
    final ptr = calloc<ffi.Uint8>(length);
    ptr.asTypedList(length).setAll(0, this);
    return ptr;
  }
}

// This constant needs to be defined
const QUICHE_PROTOCOL_VERSION = 0x00000001;