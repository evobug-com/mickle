import 'dart:async';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/connection/client_manager.dart';
import 'package:talk/core/storage/secure_storage.dart';

const int maxBackoffSeconds = 300;
final _logger = Logger('ReconnectManager');

class ReconnectManager {
  final Map<Client, ReconnectInfo> _clients = {};

  void enableReconnection(Client client) {
    final info = _clients.putIfAbsent(client, () => ReconnectInfo());
    info.serverId = client.serverId;
    info.reconnectEnabled = true;
    _logger.info('Reconnection enabled for ${client.address}');
  }

  void disableReconnection(Client client) {
    if (_clients.containsKey(client)) {
      _clients[client]!.reconnectEnabled = false;
      _clients[client]?.timer?.cancel();
      _logger.info('Reconnection disabled for ${client.address}');
    }
  }

  void onConnectionLost(Client client) {
    final info = _clients[client];
    if (info != null && info.reconnectEnabled) {
      _attemptReconnect(client);
    } else {
      _logger.info('Reconnection disabled for ${client.address} - not attempting to reconnect');
    }
  }

  void _attemptReconnect(Client client) {
    _logger.info('Attempting to reconnect to ${client.address}');
    final info = _clients[client];
    if (info == null || !info.reconnectEnabled) return;

    final delay = min(pow(2, info.attempts) + Random().nextInt(2), maxBackoffSeconds);
    _logger.info('Scheduled reconnect for ${client.address}. Attempt: ${info.attempts}. Delay: $delay seconds');

    info.timer = Timer(Duration(seconds: delay.toInt()), () async {
      try {
        await client.connect();
        _logger.info('Successfully reconnected to ${client.address}');
        info.attempts = 0; // Reset attempts on successful reconnect

        // Try logging in again with the stored credentials
        // If failed, the user will be prompted to login again
        final token = await SecureStorage().read("${info.serverId}.token");
        if(token == null) {
          _logger.warning('No token found for ${info.serverId}');

          // TODO: Notify user to login again
          ClientManager().removeClient(client);
        } else {
          final loginResult = await client.login(token: token);
          if(loginResult.error != null) {
            _logger.warning('Failed to login with token: ${loginResult.error}');

            // TODO: Notify user to login again
            ClientManager().removeClient(client);
          } else {
            _logger.info('Successfully logged in with token');
          }
        }
      } catch (e) {
        _logger.severe('Reconnection attempt failed for ${client.address}: $e');
        info.attempts++;
        if (info.reconnectEnabled) {
          _attemptReconnect(client); // Retry only if reconnection is still enabled
        }
      }
    });
  }

  ReconnectInfo get(Client client) {
    return _clients.putIfAbsent(client, () => ReconnectInfo());
  }

  void remove(Client client) {
    final info = _clients.remove(client);
    info?.timer?.cancel();
  }

  void dispose() {
    for (final client in _clients.keys) {
      _clients[client]?.timer?.cancel();
    }
    _clients.clear();
  }
}

class ReconnectInfo {
  int attempts = 0;
  bool reconnectEnabled = true;
  Timer? timer;
  String? serverId;
}