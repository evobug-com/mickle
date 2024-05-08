import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;

extension FlexBufferExt on flex_buffers.Builder {
  addStringWKey(String key, String value) {
    addKey(key);
    addString(value);
  }

  addNullWKey(String key) {
    addKey(key);
    addNull();
  }

  addIntWKey(String key, int value) {
    addKey(key);
    addInt(value);
  }

  addMapWKey(String key, Function callback) {
    startMap();
    addKey(key);
    startMap();
    callback();
    end();
    end();
  }

  addArrayWKey(String key, Function callback) {
    addKey(key);
    startVector();
    callback();
    end();
  }
}

int _requestId = 0;
getNewRequestId() {
  if(_requestId >= 65535) {
    _requestId = 0;
    return _requestId;
  }
  return _requestId++;
}

abstract class Request {
  get requestId {
    return getNewRequestId();
  }
}