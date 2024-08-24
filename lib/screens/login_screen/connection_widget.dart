import 'package:flutter/material.dart';
import 'package:talk/core/connection/client.dart';

class ConnectionWidget extends StatelessWidget {
  final Client? client;
  final VoidCallback onCancel;
  final String? errorMessage;

  const ConnectionWidget({
    Key? key,
    required this.client,
    required this.onCancel,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (client == null || errorMessage != null) {
      return _buildErrorWidget(context);
    }

    return _buildConnectingWidget(context);
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Oops! Something went wrong.'),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            SelectableText(errorMessage!),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCancel,
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: client!.connection,
      builder: (context, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Connecting to server...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}