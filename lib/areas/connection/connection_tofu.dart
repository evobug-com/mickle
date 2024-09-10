import 'dart:convert';
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'package:elliptic/elliptic.dart';
import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:talk/core/storage/secure_storage.dart';

class TOFUService {
  static final SecureStorage _secureStorage = SecureStorage();
  static final EllipticCurve _ec = getP256();

  static Future<bool> verifyServerIdentity(String connectionUrl, String serverPublicKey, String serverSignature) async {
    final storedData = await _secureStorage.read('$connectionUrl.server_data');

    if (storedData == null) {
      // First use: store the public key and signature
      await _secureStorage.write('$connectionUrl.server_data', jsonEncode({
        'publicKey': serverPublicKey,
        'signature': serverSignature,
      }));
      return true;
    } else {
      // Subsequent uses: verify the public key and signature
      final storedInfo = jsonDecode(storedData);
      if (storedInfo['publicKey'] != serverPublicKey) {
        return false; // Public key has changed
      }

      // Verify the signature
      return verifyServerSignature(connectionUrl, serverSignature, serverPublicKey);
    }
  }

  static Future<void> resetStoredKey(String connectionUrl) async {
    await _secureStorage.delete('$connectionUrl.server_data');
  }

  static Future<String> generateClientKeyPair(String connectionUrl) async {
    final privateKey = _ec.generatePrivateKey();
    final publicKey = privateKey.publicKey;

    // Store the private key securely
    await _secureStorage.write('$connectionUrl.client_private_key', privateKey.toString());

    // Return the public key for sending to the server
    return publicKey.toString();
  }

  static Future<bool> verifyServerSignature(String message, String signature, String serverPublicKey) async {
    try {
      final publicKey = _parseRawPublicKey(serverPublicKey);
      final hash = Uint8List.fromList(utf8.encode(message));
      final sig = ecdsa.Signature.fromCompact(hex.decode(signature));

      return ecdsa.verify(publicKey, hash, sig);
    } catch (e) {
      print("Error verifying signature: $e");
      return false;
    }
  }

  static Future<String?> getServerPublicKey(String connectionUrl) async {
    final storedData = await _secureStorage.read('$connectionUrl.server_data');
    if (storedData != null) {
      final storedInfo = jsonDecode(storedData);
      return storedInfo['publicKey'];
    }
    return null;
  }

  static PublicKey _parseRawPublicKey(String rawPublicKey) {
    final keyBytes = Uint8List.fromList(rawPublicKey.codeUnits);
    final X = BigInt.parse(hex.encode(keyBytes.sublist(0, 32)), radix: 16);
    final Y = BigInt.parse(hex.encode(keyBytes.sublist(32)), radix: 16);
    return PublicKey(_ec, X, Y);
  }
}