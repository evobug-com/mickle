import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mickle/areas/connection/connection.dart';
import 'package:mickle/areas/connection/connection_error.dart';

class LoginConnectionDiagnostics extends StatefulWidget {
  final String serverHost;
  final Connection connection;

  const LoginConnectionDiagnostics({
    super.key,
    required this.serverHost,
    required this.connection,
  });

  @override
  _LoginConnectionDiagnosticsState createState() => _LoginConnectionDiagnosticsState();
}

class _LoginConnectionDiagnosticsState extends State<LoginConnectionDiagnostics> {
  List<DiagnosticStep> _steps = [];
  int _currentStepIndex = -1;
  final ScrollController _scrollController = ScrollController();

  // TODO: Update the message
  String _currentStatus = 'Checking connection to the server...';

  @override
  void initState() {
    super.initState();
    _initializeDiagnosticSteps();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runDiagnostics());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeDiagnosticSteps() {
    _steps = [
      DiagnosticStep(
        name: 'Network Connection',
        check: _checkNetworkConnection,
        description: 'Checking if device is connected to a network...',
      ),
      DiagnosticStep(
        name: 'Internet Connectivity',
        check: _checkInternetConnectivity,
        description: 'Verifying internet access...',
      ),
      DiagnosticStep(
        name: 'DNS Resolution',
        check: () => _checkDnsResolution(widget.serverHost),
        description: 'Resolving server hostname...',
      ),
      DiagnosticStep(
        name: 'Server Response',
        check: () => _checkServerResponse(widget.serverHost),
        description: 'Attempting to connect to server...',
      ),
    ];
  }


  Future<void> _runDiagnostics() async {
    for (var i = 0; i < _steps.length; i++) {
      setState(() {
        _currentStepIndex = i;
        _steps[i].status = DiagnosticStatus.running;
      });

      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final result = await _steps[i].check();
        setState(() {
          _steps[i].status = result ? DiagnosticStatus.success : DiagnosticStatus.failure;
          _steps[i].message = result ? 'Success' : 'Failed';
        });
        if (!result) break;
      } catch (e) {
        setState(() {
          _steps[i].status = DiagnosticStatus.failure;
          _steps[i].message = 'Error: ${e.toString()}';
        });
        break;
      }

      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _checkNetworkConnection() async {
    // TODO: Fix the issue with the connectivity plugin (comparing List with result)
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> _checkDnsResolution(String host) async {
    try {
      await InternetAddress.lookup(host);
      return true;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> _checkServerResponse(String host) async {
    try {
      final response = await http.get(Uri.parse('http://$host:55000'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Diagnostics',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            _currentStatus,
            style: Theme.of(context).textTheme.bodyMedium,
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: _steps.asMap().entries.map((entry) {
                  int idx = entry.key;
                  DiagnosticStep step = entry.value;
                  return _buildDiagnosticStep(step, idx <= _currentStepIndex)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slide(begin: const Offset(0, -0.5), end: Offset.zero);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildDiagnosticStep(DiagnosticStep step, bool isVisible) {
    if (!isVisible) return const SizedBox.shrink();

    IconData icon;
    Color color;
    String statusText;

    switch (step.status) {
      case DiagnosticStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
        statusText = 'Pending';
        break;
      case DiagnosticStatus.running:
        icon = Icons.refresh;
        color = Theme.of(context).colorScheme.primary;
        statusText = 'Running';
        break;
      case DiagnosticStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'Success';
        break;
      case DiagnosticStatus.failure:
        icon = Icons.error;
        color = Theme.of(context).colorScheme.error;
        statusText = 'Failed';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: step.status == DiagnosticStatus.running
                    ? CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                )
                    : Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                statusText,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (step.status == DiagnosticStatus.running)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Text(
                step.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          if (step.status == DiagnosticStatus.failure && step.name == 'Server Response')
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: SelectableText(
                _getDetailedErrorMessage(widget.connection.error),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
        ],
      ),
    );
  }

  String _getDetailedErrorMessage(ConnectionError? error) {
    if (error == null) {
      return 'Unknown error occurred';
    }

    String baseMessage = '${error.type}: ${error.message}';

    if (error.details.isNotEmpty) {
      String detailsStr = error.details.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      return '$baseMessage\nDetails: $detailsStr';
    }

    return baseMessage;
  }

}

class DiagnosticStep {
  final String name;
  final Future<bool> Function() check;
  final String description;
  DiagnosticStatus status;
  String? message;

  DiagnosticStep({
    required this.name,
    required this.check,
    required this.description,
    this.status = DiagnosticStatus.pending,
    this.message,
  });
}

enum DiagnosticStatus {
  pending,
  running,
  success,
  failure,
}