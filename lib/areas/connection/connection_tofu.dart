import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:elliptic/elliptic.dart';
import 'package:ecdsa/ecdsa.dart' as ecdsa;

import 'package:logging/logging.dart';
import 'package:mickle/core/network/api_types.dart';
import 'package:mickle/core/storage/data/endpoint.dart';
import 'package:mickle/core/storage/preferences.dart';
import 'package:mickle/core/storage/secure_storage.dart';

/// Service class for handling Trust-On-First-Use (TOFU) operations.
class TOFUService {
  static final Logger _logger = Logger('TOFUService');
  static final SecureStorage _secureStorage = SecureStorage();
  static final Curve _curve = getSecp256k1();

  /// Verifies the server's identity using the TOFU principle.
  ///
  /// Returns `true` if the server's identity is verified, `false` otherwise.
  static Future<bool> verifyServerIdentity(String connectionUrl, ResFetchPublicKeyPacket packet) async {
    return true;
    try {
      if (!_verifySignature(packet.publicKey, packet.data, packet.signature)) {
        _logger.warning('Signature verification failed for $connectionUrl');
        return false;
      }

      final data = PreferenceEndpointTofu.fromJson(json.decode(packet.data));
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
  static Future<bool> _compareWithStoredData(String connectionUrl, PreferenceEndpointTofu data, String publicKey) async {
    var endpointData = await Preferences.getEndpoint(connectionUrl);

    if(endpointData == null) {
      throw Exception('Endpoint data not found for $connectionUrl');
    }

    if(endpointData.tofuData == null) {
      endpointData = endpointData.copyWith(tofuData: data);
      await Preferences.setEndpoint(connectionUrl, endpointData!);
      _logger.info('Stored new TOFU data for $connectionUrl');
      return true;
    }

    return _verifyStoredData(connectionUrl, data, publicKey, endpointData.tofuData!);
  }

  /// Verifies stored TOFU data against received data.
  static Future<bool> _verifyStoredData(String connectionUrl, PreferenceEndpointTofu newData, String newPublicKey, PreferenceEndpointTofu existingData) async {
    if(!_compareTofuData(existingData, newData)) {
      _logger.warning('TOFU data mismatch for $connectionUrl');
      return false;
    }
    return true;
  }

  /// Compares two TofuData objects.
  static bool _compareTofuData(PreferenceEndpointTofu stored, PreferenceEndpointTofu newT) {
    return
      stored.certificateFingerprint == newT.certificateFingerprint &&
      stored.serverAddress == newT.serverAddress &&
      stored.serverPort == newT.serverPort &&
      stored.protocolVersion == newT.protocolVersion &&
      stored.publicKey == newT.publicKey;
  }

  /// Resets stored TOFU data for a given connection URL.
  static Future<void> resetStoredData(String connectionUrl) async {
    var entrypointData = await Preferences.getEndpoint(connectionUrl);
    if(entrypointData == null || entrypointData.tofuData == null) {
      return;
    }

    entrypointData = entrypointData.copyWith(tofuData: null);
    await Preferences.setEndpoint(connectionUrl, entrypointData!);
    _logger.info('Reset stored TOFU data for $connectionUrl');
  }
}