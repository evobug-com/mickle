
import 'package:audioplayers/audioplayers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/models/models.dart';

import '../../../../core/managers/audio_manager.dart';
import '../../../../core/connection/client.dart';
final _logger = Logger("VoiceRoomCurrent");

class VoiceRoomCurrent extends ChangeNotifier {
  Channel? _currentChannel;
  Channel? get currentChannel => _currentChannel;

  // DtlsClient? _dtlsClient;
  // DtlsConnection? _dtlsConnection;

  _showError(String message, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    BotToast.showNotification(
      title: (_) => Text("Failed to join voice channel", style: TextStyle(color: scheme.onError)),
      subtitle: (_) => Text(message, style: TextStyle(color: scheme.onError)),
      duration: const Duration(seconds: 50),
      backgroundColor: scheme.error,
    );
  }

  void joinVoice(Client client, Channel channel) async {
    // _logger.info("Joining voice channel ${channel.id}");
    // AudioManager.playSingleShot("SFX", AssetSource("audio/enter_voice.wav"));
    // _currentChannel = channel;
    // notifyListeners();
    // // Request to join the voice channel
    // final packetManager = PacketManager(client);
    // _logger.info("Sending join voice channel request");
    // final response = await packetManager.sendJoinVoiceChannel(channelId: channel.id);
    // _logger.info("Received response to join voice channel");
    //
    // _logger.info("Resolving voice server address");
    // final voiceServerAddress = (await InternetAddress.lookup(client.address.host)).first;
    // _logger.info("Voice server address resolved to ${voiceServerAddress.address}");
    // final voiceServerPort = 56000;
    //
    // if (response.error != null) {
    //   print("Failed to join voice channel ${channel.id} with error ${response.error}");
    //   leaveVoice();
    //   _showError(response.error!);
    // } else {
    //   print("Connecting to voice channel ${channel.id}");
    //   final token = response.token!;
    //
    //   _dtlsClient = await DtlsClient.bind("::", 0);
    //   try {
    //     final context = DtlsClientContext(
    //       verify: true,
    //       withTrustedRoots: true,
    //       // ciphers: "TLS_AES_128_GCM_SHA256",
    //       // pskCredentialsCallback: (identityHint) {
    //       //   return PskCredentials(
    //       //     identity: Uint8List.fromList(utf8.encode("Client_identity")),
    //       //     preSharedKey: Uint8List.fromList(utf8.encode("secretPSK")),
    //       //   );
    //       // },
    //     );
    //
    //     _dtlsConnection = await _dtlsClient!.connect(
    //       voiceServerAddress,
    //       voiceServerPort,
    //       context,
    //       timeout: Duration(seconds: 5),
    //     );
    //   } on TimeoutException {
    //     await _dtlsClient!.close();
    //     rethrow;
    //   } catch (e) {
    //     print("Failed to connect to voice server: $e");
    //     _showError(e.toString());
    //     leaveVoice();
    //   }
    //
    //   if(_dtlsConnection == null) {
    //     return;
    //   }
    //
    //   _dtlsConnection!.listen((datagram) async {
    //     print("Received voice packet");
    //   }, onDone: () {
    //     print("Voice connection closed");
    //     leaveVoice();
    //   }, onError: (e) {
    //     print("Voice connection error: $e");
    //     _showError(e.toString());
    //     leaveVoice();
    //   });
    //
    //   _dtlsConnection!.send(utf8.encode(token));
    // }
  }

  void leaveVoice() async {
    AudioManager.playSingleShot("SFX", AssetSource("audio/leave_voice.wav"));
    _currentChannel = null;
    notifyListeners();
  }

  static of(BuildContext context, {bool listen = true}) {
    return Provider.of<VoiceRoomCurrent>(context, listen: listen);
  }
}