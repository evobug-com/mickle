import 'package:flutter/material.dart';

class Disposable extends StatefulWidget {
  final Widget child;
  final void Function() onDispose;

  const Disposable({
    super.key,
    required this.child,
    required this.onDispose,
  });

  @override
  DisposableState createState() => DisposableState();
}

class DisposableState extends State<Disposable> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}