
import 'package:flutter/material.dart';

class SettingTitle extends StatelessWidget {
  final String? title;
  const SettingTitle({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title!, style: Theme.of(context).textTheme.displaySmall);
  }
}

class Highlightable extends StatelessWidget {
  final bool highlight;
  final Widget child;

  const Highlightable({super.key, required this.child, required this.highlight});

  @override
  Widget build(BuildContext context) {
    if (highlight) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          // Right aligned text Found
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("Found", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
            child: Row(
              children: [
                Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.primary),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      );
    }
    return child;
  }
}
