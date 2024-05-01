
class ListenerList {
  final List<Function> _listeners = [];

  void add(Function listener) {
    _listeners.add(listener);
  }

  void remove(Function listener) {
    _listeners.remove(listener);
  }

  void notify() {
    for (final listener in _listeners) {
      listener();
    }
  }
}