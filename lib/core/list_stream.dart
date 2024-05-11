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
  List<Relation> _relations = [];
  Map<String, List<Relation>> _inputIndex = {};
  Map<String, List<Relation>> _outputIndex = {};

  final _controller = StreamController<Relation>.broadcast();

  Stream<Relation> get stream => _controller.stream;

  void addRelation(Relation relation) {
    _relations.add(relation);
    _inputIndex.putIfAbsent(relation.input, () => []).add(relation);
    _outputIndex.putIfAbsent(relation.output, () => []).add(relation);
    _controller.add(relation);
  }

  void removeRelation(Relation relation) {
    _relations.remove(relation);
    _inputIndex[relation.input]?.remove(relation);
    _outputIndex[relation.output]?.remove(relation);
    _controller.add(relation);
  }

  void clear() {
    _relations.clear();
    _inputIndex.clear();
    _outputIndex.clear();
    for (var relation in _relations) {
      _controller.add(relation);
    }
  }

  void addRelations(List<Relation> relations) {
    for (var relation in relations) {
      addRelation(relation);
    }
  }

  List<Relation> inputs(String id) {
    return _inputIndex[id] ?? [];
  }

  List<Relation> outputs(String id) {
    return _outputIndex[id] ?? [];
  }

  dispose() {
    _controller.close();
  }

  void removeRelationInput(String id) {
    final removed = _inputIndex.remove(id);
    if (removed != null) {
      removed.forEach((relation) {
        removeRelation(relation);
        _relations.remove(relation);
      });
    }
  }

  void removeRelationOutput(String id) {
    final removed = _outputIndex.remove(id);
    if (removed != null) {
      removed.forEach((relation) {
        removeRelation(relation);
        _relations.remove(relation);
      });
    }
  }
}