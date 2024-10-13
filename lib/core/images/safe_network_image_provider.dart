import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SafeNetworkImageProvider extends ImageProvider<SafeNetworkImageProvider> {
  const SafeNetworkImageProvider(
      this.url, {
        this.scale = 1.0,
        this.headers,
        this.defaultAssetPath = 'assets/images/default_avatar.png',
      });

  final String? url;
  final double scale;
  final Map<String, String>? headers;
  final String defaultAssetPath;

  @override
  Future<SafeNetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SafeNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(SafeNetworkImageProvider key, ImageDecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url ?? 'null',
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<String?>('URL', url),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
      SafeNetworkImageProvider key,
      ImageDecoderCallback decode,
      StreamController<ImageChunkEvent> chunkEvents,
      ) async {
    try {
      assert(key == this);

      if (key.url == null || key.url!.isEmpty) {
        return _loadDefaultImage(decode);
      }

      final Uri? resolved = Uri.tryParse(key.url!);
      if (resolved == null || !resolved.hasScheme) {
        return _loadDefaultImage(decode);
      }

      final http.Response response = await http.get(
        resolved,
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('Failed to load image: incorrect status code ${response.statusCode} ${response.reasonPhrase}');
        return _loadDefaultImage(decode);
      }

      final String? contentType = response.headers['content-type'];
      if (contentType == null || !contentType.startsWith('image/')) {
        print('Failed to load image: wrong content-type $contentType ${response.reasonPhrase}');
        return _loadDefaultImage(decode);
      }

      final Uint8List bytes = response.bodyBytes;
      if (bytes.lengthInBytes == 0) {
        print('Failed to load image: empty image ${response.reasonPhrase}');
        return _loadDefaultImage(decode);
      }

      final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      print('Failed to load image: $e');
      // If any error occurs, load the default image
      return _loadDefaultImage(decode);
    } finally {
      await chunkEvents.close();
    }
  }

  Future<ui.Codec> _loadDefaultImage(ImageDecoderCallback decode) async {
    final ByteData data = await rootBundle.load(defaultAssetPath);
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(data.buffer.asUint8List());
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SafeNetworkImageProvider
        && other.url == url
        && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'SafeNetworkImageProvider')}("$url", scale: $scale)';
}