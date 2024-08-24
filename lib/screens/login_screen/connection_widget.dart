import 'package:flutter/material.dart';
import 'package:talk/core/connection/client.dart';

import '../../generated/l10n.dart';

class ConnectionWidget extends StatelessWidget {
  final Client? client;
  final VoidCallback onCancel;
  final String? errorMessage;

  const ConnectionWidget({
    super.key,
    required this.client,
    required this.onCancel,
    this.errorMessage,
  });

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
          Text(S.of(context).loginScreenOopsSomethingWentWrong),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            SelectableText(errorMessage!),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCancel,
            child: Text(S.of(context).loginScreenGoBack),
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
              Text(S.of(context).loginScreenConnectingToServer),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCancel,
                child: Text(S.of(context).loginScreenCancel),
              ),
            ],
          ),
        );
      },
    );
  }
}