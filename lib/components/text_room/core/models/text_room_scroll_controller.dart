import 'package:flutter/cupertino.dart';

class CachedScrollController {
  final ScrollController controller;
  double? position;

  factory CachedScrollController() {
    final ScrollController controller = ScrollController();
    final cached = CachedScrollController._(controller, 0);
    controller.addListener(() {
      cached.position = controller.position.pixels;
    });
    return cached;
  }

  CachedScrollController._(this.controller, this.position);

  bool get hasClients => controller.hasClients;

  jumpToCached() {
    controller.jumpTo(position!);
  }

  scrollToBottom() {
    controller.jumpTo(controller.position.maxScrollExtent);
  }

  void dispose() {
    controller.dispose();
  }
}

class TextRoomScrollController extends ChangeNotifier {
  bool nextRenderScrollToBottom = false;
  final Map<String, CachedScrollController> controllers = {};

  @override void dispose() {
    for (var element in controllers.values) {
      element.dispose();
    }
    super.dispose();
  }
}