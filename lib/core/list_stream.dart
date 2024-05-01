import 'dart:async';

import 'package:talk/core/models/models.dart';



// Function to prepare a string of id based on runtimeType
String idFromType<T>(T item) => '${item.runtimeType}:${(item as dynamic)?.id}';

class ListStream<T> {
  final Map<String, T> _items = {};
  final _controller = StreamController<List<T>>.broadcast();

  Stream<List<T>> get stream => _controller.stream;

  get items => _items.values.toList();

  void addItem(T item) {
    // Update or add the item by its unique ID.
    _items[idFromType(item)] = item;
    // Emit the updated list of items.
    _controller.add(List.unmodifiable(_items.values));
  }

  void addItems(List<T> items) {
    for (var item in items) {
      _items[idFromType(item)] = item;
    }
    _controller.add(List.unmodifiable(_items.values));
  }

  void removeItem(T item) {
    _items.remove(idFromType(item));
    _controller.add(List.unmodifiable(_items.values));
  }

  void clear() {
    _items.clear();
    _controller.add(List.unmodifiable(_items.values));
  }

  void dispose() {
    _controller.close();
  }

  T? firstWhere(bool Function(T element) param0) {
    return _items.values.firstWhere((element) => param0(element));
  }

  get(String id) {
    return _items[id];
  }
}