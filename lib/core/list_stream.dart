import 'dart:async';
import 'package:collection/collection.dart';

import 'models/models.dart';



// Function to prepare a string of id based on runtimeType
String idFromType<T>(T item) => '${item.runtimeType}:${(item as dynamic)?.id}';

class ListStream<T> {
  final Map<String, T> _items = {};
  final _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  List<T> get items => _items.values.toList();

  void addItem(T item) {
    // Update or add the item by its unique ID.
    _items[idFromType(item)] = item;
    // Emit the updated list of items.
    for (var item in _items.values) {
      _controller.add(item);
    }
  }

  void addItems(List<T> items) {
    for (var item in items) {
      _items[idFromType(item)] = item;
      _controller.add(item);
    }
  }

  void removeItem(T item) {
    _items.remove(idFromType(item));
    _controller.add(item);
  }

  void clear() {
    _items.clear();
    for (var item in _items.values) {
      _controller.add(item);
    }
  }

  void dispose() {
    _controller.close();
  }

  T firstWhere(bool Function(T element) param0) {
    return _items.values.firstWhere((element) => param0(element));
  }

  T? firstWhereOrNull(bool Function(T element) param0) {
    return _items.values.firstWhereOrNull((element) => param0(element));
  }

  T? get(String id) {
    return _items[id];
  }
}

class RelationListStream {
  final Map<String, String> _relationsIn = {};
  final Map<String, String> _relationsOut = {};
  final _controller = StreamController<Relation>.broadcast();

  Stream<Relation> get stream => _controller.stream;

  void addRelation(Relation relation) {
    _relationsIn[relation.input] = relation.output;
    _relationsOut[relation.output] = relation.input;
    _controller.add(relation);
  }

  void removeRelation(Relation relation) {
    _relationsIn.remove(relation.input);
    _relationsOut.remove(relation.output);
    _controller.add(relation);
  }

  void clear() {
    _relationsIn.clear();
    _relationsOut.clear();
  }

  void addRelations(List<Relation> relations) {
    for (var relation in relations) {
      _relationsIn[relation.input] = relation.output;
      _relationsOut[relation.output] = relation.input;
      _controller.add(relation);
    }
  }

  input(String id) {
    return _relationsIn[id];
  }

  output(String id) {
    return _relationsOut[id];
  }

  dispose() {
    _controller.close();
  }
}