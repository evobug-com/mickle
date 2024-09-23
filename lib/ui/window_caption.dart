import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import '../core/providers/global/update_provider.dart';

const double kWindowCaptionHeight = 40;

class WindowCaption extends StatefulWidget {
  const WindowCaption({
    super.key,
    this.title,
    this.backgroundColor,
    this.brightness,
    this.disableExit = false, required this.showSearchBar,
  });

  final Widget? title;
  final Color? backgroundColor;
  final Brightness? brightness;
  final bool disableExit;
  final bool showSearchBar;

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
                    if(widget.showSearchBar)
                      Expanded(
                        child: Center(
                            child: _buildSearchField()
                        ),
                      )
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

  TextField _buildSearchField() {
    return TextField(
      enabled: false,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        isDense: true,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: 30,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        filled: true,
        hintText: 'What are you looking for?',
        prefixIcon: Icon(Icons.search),
      ),
      expands: false,
      minLines: 1,
      maxLines: 1,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildUpdateIcon(BuildContext context) {
    return Tooltip(
      message: 'Update available',
      child: InkWell(
        onTap: () {
          // Navigate to update screen
          context.goNamed('update');
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