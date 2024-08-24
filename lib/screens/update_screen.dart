import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/version.dart';
import '../core/providers/global/update_provider.dart';
import '../core/autoupdater/autoupdater.dart';
import '../layout/my_scaffold.dart';

final _logger = Logger('UpdateScreen');

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  int? _currentStep;
  ProgressInfo? _currentProgress;
  bool _isUpdateInProgress = false;

  final List<UpdateStep> _steps = [
    UpdateStep(icon: Icons.refresh, title: 'Preparing', description: 'Initializing update process'),
    UpdateStep(icon: Icons.download, title: 'Downloading', description: 'Fetching new version'),
    UpdateStep(icon: Icons.security, title: 'Verifying', description: 'Checking integrity of downloaded files'),
    UpdateStep(icon: Icons.system_update_alt, title: 'Installing', description: 'Applying updates'),
    UpdateStep(icon: Icons.check_circle, title: 'Finalizing', description: 'Cleaning up and preparing to restart'),
  ];

  @override
  Widget build(BuildContext context) {
    final updateProvider = context.watch<UpdateProvider>();
    final updateInfo = updateProvider.updateInfo;
    final colorScheme = Theme.of(context).colorScheme;

    return MyScaffold(
      showSidebar: false,
      body: Container(
        color: colorScheme.background,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left side: Update details and controls
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Available',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A new version of Talk is ready!',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildVersionInfo(colorScheme, updateInfo),
                        const SizedBox(height: 24),
                        Text(
                          'Release Notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                updateInfo.getReleaseNotes(),
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                        if (!_isUpdateInProgress) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _startUpdate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                  ),
                                  child: Text('Update Now'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () {
                                  updateProvider.skipUpdate();
                                  context.go('/chat');
                                },
                                child: const Text('Update Later'),
                              ),
                            ],
                          ),
                        ],
                        if(_isUpdateInProgress) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Please wait while the update is in progress...',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Right side: Update steps
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: UpdateProgressIndicator(
                      currentStep: _currentStep,
                      steps: _steps,
                      currentProgress: _currentProgress,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo(ColorScheme colorScheme, UpdateInfo updateInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVersionCard(colorScheme, 'Current', version),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.arrow_forward, color: colorScheme.primary, size: 24),
            ),
            _buildVersionCard(colorScheme, 'New', updateInfo.latestVersion.toString()),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Update Size: ${_formatSize(updateInfo.updateSize)}',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionCard(ColorScheme colorScheme, String label, String version) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          version,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatSize(int? sizeInBytes) {
    if (sizeInBytes == null) return 'Unknown';
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = sizeInBytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }

  void _startUpdate() async {
    final updater = AutoUpdater();

    setState(() {
      _isUpdateInProgress = true;

      // Set the initial step when update starts
      _currentStep = 0;
    });

    for (int i = 0; i < _steps.length; i++) {
      setState(() => _currentStep = i);
      try {
        await updater.performUpdateStep(i, (progress) {
          setState(() {
            _currentProgress = progress;
          });
        });
      } catch (e) {
        _logger.severe('Error during update step $i: $e');
        // Handle error (e.g., show error message to user)
        break;
      }
    }

    setState(() {
      _currentStep = null;
      _currentProgress = null;
    });

    _logger.info('Update completed. The app will now restart.');
  }
}

class UpdateProgressIndicator extends StatelessWidget {
  final int? currentStep;
  final List<UpdateStep> steps;
  final ProgressInfo? currentProgress;

  const UpdateProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.steps,
    this.currentProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = currentStep != null && index == currentStep;
        final isCompleted = currentStep != null && index < currentStep!;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primaryContainer : (isCompleted ? colorScheme.surfaceVariant : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(step.icon, isActive, isCompleted, colorScheme),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isActive || isCompleted ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive || isCompleted ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isActive && currentProgress != null && currentProgress!.message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: currentProgress!.progress,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentProgress!.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        if (currentProgress!.bytesProcessed != null && currentProgress!.totalBytes != null)
                          Text(
                            '${_formatSize(currentProgress!.bytesProcessed!)} / ${_formatSize(currentProgress!.totalBytes!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        if (currentProgress!.speed != null)
                          Text(
                            'Speed: ${_formatSize(currentProgress!.speed!.round())}/s',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ).animate()
              .scale(duration: 300.ms, curve: Curves.easeInOut)
              .fade(duration: 300.ms, curve: Curves.easeInOut),
        );
      }).toList(),
    );
  }

  Widget _buildIcon(IconData icon, bool isActive, bool isCompleted, ColorScheme colorScheme) {
    final color = isCompleted ? colorScheme.secondary : (isActive ? colorScheme.primary : colorScheme.onSurfaceVariant.withOpacity(0.5));
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon, size: 24, color: color),
        if (isActive)
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1.seconds, curve: Curves.linear),
      ],
    );
  }

  String _formatSize(int sizeInBytes) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = sizeInBytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }
}

class UpdateStep {
  final IconData icon;
  final String title;
  final String description;

  UpdateStep({required this.icon, required this.title, required this.description});
}