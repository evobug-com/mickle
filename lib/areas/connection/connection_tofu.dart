import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:elliptic/elliptic.dart';
import 'package:ecdsa/ecdsa.dart' as ecdsa;

import 'package:logging/logging.dart';
import 'package:mickle/core/network/api_types.dart';
import 'package:mickle/core/storage/secure_storage.dart';

/// Represents the Trust-On-First-Use (TOFU) data received from the server.
class TofuData {
  final String certificateFingerprint;
  final String serverAddress;
  final int serverPort;
  final int protocolVersion;

  const TofuData({
    required this.certificateFingerprint,
    required this.serverAddress,
    required this.serverPort,
    required this.protocolVersion,
  });

  factory TofuData.fromJson(Map<String, dynamic> json) => TofuData(
    certificateFingerprint: json['certificate_fingerprint'] as String,
    serverAddress: json['server_address'] as String,
    serverPort: json['server_port'] as int,
    protocolVersion: json['protocol_version'] as int,
  );

  Map<String, dynamic> toJson() => {
    'certificate_fingerprint': certificateFingerprint,
    'server_address': serverAddress,
    'server_port': serverPort,
    'protocol_version': protocolVersion,
  };
}

/// Service class for handling Trust-On-First-Use (TOFU) operations.
class TOFUService {
  static final Logger _logger = Logger('TOFUService');
  static final SecureStorage _secureStorage = SecureStorage();
  static final Curve _curve = getSecp256k1();

  /// Verifies the server's identity using the TOFU principle.
  ///
  /// Returns `true` if the server's identity is verified, `false` otherwise.
  static Future<bool> verifyServerIdentity(String connectionUrl, ResFetchPublicKeyPacket packet) async {
    try {
      if (!_verifySignature(packet.publicKey, packet.data, packet.signature)) {
        _logger.warning('Signature verification failed for $connectionUrl');
        return false;
      }

      final data = TofuData.fromJson(json.decode(packet.data));
      return await _compareWithStoredData(connectionUrl, data, packet.publicKey);
    } catch (e) {
      _logger.severe('Error in verifyServerIdentity: $e');
      return false;
    }
  }

  /// Verifies the signature of the data.
  static bool _verifySignature(String publicKeyHex, String data, String signatureHex) {
    try {
      final publicKey = _curve.compressedHexToPublicKey(publicKeyHex);
      final digest = sha256.convert(utf8.encode(data));
      final signature = ecdsa.Signature.fromCompactHex(signatureHex);

      return ecdsa.verify(
        publicKey,
        digest.bytes,
        signature,
      );
    } catch (e) {
      _logger.warning('Error in _verifySignature: $e');
      return false;
    }
  }


  /// Compares the received data with stored data.
  static Future<bool> _compareWithStoredData(String connectionUrl, TofuData data, String publicKey) async {
    final storedDataJson = await _secureStorage.read('$connectionUrl.server_data');
    if (storedDataJson == null) {
      await _storeNewData(connectionUrl, data, publicKey);
      return true;
    } else {
      return _verifyStoredData(connectionUrl, data, publicKey, storedDataJson);
    }
  }

  /// Stores new TOFU data.
  static Future<void> _storeNewData(String connectionUrl, TofuData data, String publicKey) async {
    await _secureStorage.write('$connectionUrl.server_data', json.encode(data.toJson()));
    await _secureStorage.write('$connectionUrl.public_key', publicKey);
    _logger.info('Stored new TOFU data for $connectionUrl');
  }

  /// Verifies stored TOFU data against received data.
  static Future<bool> _verifyStoredData(String connectionUrl, TofuData newData, String newPublicKey, String storedDataJson) async {
    final storedPublicKey = await _secureStorage.read('$connectionUrl.public_key');
    if (storedPublicKey != newPublicKey) {
      _logger.warning('Public key mismatch for $connectionUrl');
      return false;
    }
    final storedData = TofuData.fromJson(json.decode(storedDataJson));
    return _compareTofuData(storedData, newData);
  }

  /// Compares two TofuData objects.
  static bool _compareTofuData(TofuData stored, TofuData newT) {
    return
      stored.certificateFingerprint == newT.certificateFingerprint &&
      stored.serverAddress == newT.serverAddress &&
      stored.serverPort == newT.serverPort &&
      stored.protocolVersion == newT.protocolVersion;
  }

  /// Resets stored TOFU data for a given connection URL.
  static Future<void> resetStoredData(String connectionUrl) async {
  await _secureStorage.delete('$connectionUrl.server_data');
  await _secureStorage.delete('$connectionUrl.public_key');
  _logger.info('Reset stored TOFU data for $connectionUrl');
  }

  /// Retrieves the stored public key for a given connection URL.
  static Future<String?> getStoredPublicKey(String connectionUrl) async {
  return await _secureStorage.read('$connectionUrl.public_key');
  }
}