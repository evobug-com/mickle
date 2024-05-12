import 'dart:async';

extension FutureCompleter on Future {
  Completer<T> wrapInCompleter<T>() {
    final completer = Completer<T>();
    then((value) {
      completer.complete(value);
    }).catchError((error) {
      completer.completeError(error);
    });
    return completer;
  }
}