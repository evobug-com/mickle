import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/components/server_list/components/server_list_navigator.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import '../core/providers/global/update_provider.dart';

const double kWindowCaptionHeight = 32;

class WindowCaption extends StatefulWidget {
  const WindowCaption({
    super.key,
    this.title,
    this.backgroundColor,
    this.brightness,
    this.disableExit = false,
  });

  final Widget? title;
  final Color? backgroundColor;
  final Brightness? brightness;
  final bool disableExit;

  @override
  State<WindowCaption> createState() => _WindowCaptionState();
}

class _WindowCaptionState extends State<WindowCaption> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = context.watch<UpdateProvider>();
    final hasPostponedUpdate = updateProvider.updateInfo.updateAvailable && !updateProvider.updateAvailable;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: widget.brightness == Brightness.light
                              ? Colors.black.withOpacity(0.8956)
                              : Colors.white,
                          fontSize: 14,
                        ),
                        child: widget.title ?? Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasPostponedUpdate) _buildUpdateIcon(context),
          WindowCaptionButton.minimize(
            brightness: widget.brightness,
            onPressed: () async {
              bool isMinimized = await windowManager.isMinimized();
              if (isMinimized) {
                windowManager.restore();
              } else {
                windowManager.minimize();
              }
            },
          ),
          FutureBuilder<bool>(
            future: windowManager.isMaximized(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == true) {
                return WindowCaptionButton.unmaximize(
                  brightness: widget.brightness,
                  onPressed: () {
                    windowManager.unmaximize();
                  },
                );
              }
              return WindowCaptionButton.maximize(
                brightness: widget.brightness,
                onPressed: () {
                  windowManager.maximize();
                },
              );
            },
          ),
          WindowCaptionButton.close(
            brightness: widget.brightness,
            onPressed: () {
              if(!widget.disableExit) {
                windowManager.close();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateIcon(BuildContext context) {
    return Tooltip(
      message: 'Update available',
      child: InkWell(
        onTap: () {
          // Navigate to update screen
          context.go('/update');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.system_update,
                size: 16,
                color: widget.brightness == Brightness.light
                    ? Colors.blue[700]
                    : Colors.blue[300],
              ),
              const SizedBox(width: 4),
              Text(
                'Update',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.brightness == Brightness.light
                      ? Colors.blue[700]
                      : Colors.blue[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }
}