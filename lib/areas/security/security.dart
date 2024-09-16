import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'security_provider.dart';

class SecurityWidget extends StatelessWidget {
  const SecurityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityWarningsProvider>(
      builder: (context, warningsProvider, child) {
        final warnings = warningsProvider.warnings;

        if (warnings.isEmpty) return const SizedBox.shrink();

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              ModalBarrier(dismissible: false, color: Colors.black54),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Card(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: warnings.map((warning) => _buildWarningAlert(context, warning)).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWarningAlert(BuildContext context, SecurityWarning warning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Security Warning', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          SizedBox(height: 8),
          SelectableText(warning.message),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  warning.onDismiss(warning);
                },
              ),
              SizedBox(width: 8),
              ElevatedButton(
                child: Text('Proceed Anyway'),
                onPressed: () {
                  warning.onProceed(warning);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}