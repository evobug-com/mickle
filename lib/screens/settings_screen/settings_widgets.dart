
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mickle/areas/utilities/elevation.dart';
import 'package:mickle/screens/settings_screen/settings_models.dart';

class SettingTitle extends StatelessWidget {
  final SettingMetadata category;
  final String? subtitle;
  const SettingTitle({super.key, required this.category, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              this.category.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            BackButton(
             onPressed: () {
               context.pop();
             },
            )
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class Highlightable extends StatelessWidget {
  final bool highlight;
  final Widget child;

  const Highlightable({super.key, required this.child, required this.highlight});

  @override
  Widget build(BuildContext context) {
    if (highlight) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: child),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  "Found",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return child;
  }
}

Widget buildSettingsSection(BuildContext context, String title, List<Widget> children) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Elevation(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    ),
  );
}

Widget buildSettingSwitchOption({required BuildContext context, required String title, required String description, required IconData icon, required bool value, required ValueChanged<bool> onChanged}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    width: 400,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colorScheme.surfaceVariant.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
    ),
    child: Row(
      children: [
        Icon(icon, color: colorScheme.onSurface, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    ),
  ).animate().fadeIn(delay: 300.ms).scale();
}

