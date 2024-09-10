import 'dart:io';

class ConnectionError {
  final String type;
  final String message;
  final dynamic exception;

  ConnectionError._internal(this.type, this.message, this.exception);

  factory ConnectionError.socketException(SocketException e) {
    return ConnectionError._internal('SocketException', e.toString(), e);
  }

  factory ConnectionError.handshakeException(HandshakeException e) {
    return ConnectionError._internal('HandshakeException', e.toString(), e);
  }

  factory ConnectionError.certificateException(CertificateException e) {
    return ConnectionError._internal('CertificateException', e.toString(), e);
  }

  factory ConnectionError.tlsException(TlsException e) {
    return ConnectionError._internal('TlsException', e.toString(), e);
  }

  factory ConnectionError.osError(OSError e) {
    return ConnectionError._internal('OSError', e.toString(), e);
  }

  factory ConnectionError.authenticationFailed(String errorMessage) {
    return ConnectionError._internal('AuthenticationFailed', errorMessage, null);
  }

  factory ConnectionError.tofuError(String errorMessage) {
    return ConnectionError._internal('TofuError', errorMessage, null);
  }

  factory ConnectionError.unknown(dynamic e) {
    return ConnectionError._internal('UnknownError', e.toString(), e);
  }

  Map<String, dynamic> get details {
    if (exception is SocketException) {
      final e = exception as SocketException;
      return {
        'address': e.address?.address,
        'port': e.port,
        'osError': e.osError?.message
      };
    } else if (exception is TlsException) {
      final e = exception as TlsException;
      return {'osError': e.osError?.message};
    } else if (exception is OSError) {
      final e = exception as OSError;
      return {'errorCode': e.errorCode};
    }
    return {};
  }

  static ConnectionError fromException(dynamic e) {
    if (e is SocketException) {
      return ConnectionError.socketException(e);
    } else if (e is HandshakeException) {
      return ConnectionError.handshakeException(e);
    } else if (e is CertificateException) {
      return ConnectionError.certificateException(e);
    } else if (e is TlsException) {
      return ConnectionError.tlsException(e);
    } else if (e is OSError) {
      return ConnectionError.osError(e);
    } else {
      return ConnectionError.unknown(e);
    }
  }

  @override
  String toString() {
    return '$type: $message';
  }
}