import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/connection/client_manager.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';

import '../core/connection/client.dart';
import '../core/notifiers/theme_controller.dart';
import '../core/storage/secure_storage.dart';
import '../main.dart';

bool firstStart = true;

final _logger = Logger('LoginScreen');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final TextEditingController _serverHostController = TextEditingController(text: kDebugMode ? "localhost" : "vps.sionzee.cz");
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Client? _client;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;

  void setErrorMessage(String message) {
    _errorMessage = message;
  }


  @override
  initState() {
    super.initState();
    _init();
  }

  _init() async {
    if(!firstStart) {
      return;
    }

    firstStart = false;

    List<dynamic> servers = jsonDecode(await SecureStorage().read("servers") ?? "[]");
    if(servers.isNotEmpty) {
      _logger.fine("Connecting to servers: $servers");

      // Get all servers and try to open a connection
      final futures = <Completer<String?>>[];
      for(final server in servers) {
        final token = await SecureStorage().read("$server.token");
        final host = await SecureStorage().read("$server.host");
        if(token != null && host != null) {
          _logger.fine("Connecting to server $server");
          final completer = Completer<String?>();
          await _connect(
              address: ClientAddress(
                  host: host,
                  port: 55000
              ),
              onError: (client, message) {
                completer.complete(message);
              },
              onSuccess: (client) {
                completer.complete(null);
              },
              token: token
          );
          futures.add(completer);
        }
      }

      // Wait for all connections to be established
      List<String?> results = await Future.wait(futures.map((e) => e.future));
      _logger.fine("Connection results: $results");
      if(mounted && results.any((element) => element == null)) {
        final successClient = ClientManager().clients.firstWhereOrNull((element) => element.connection.state == ClientConnectionState.connected && element.userId != null);
        if(successClient != null) {
          CurrentClientProvider.of(context, listen: false).selectClient(successClient);
          context.go('/');
        } else {
          _logger.warning("No client was successfully connected.");
        }
      }
    }
  }

  @override
  void dispose() {
    _serverHostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect({
    required ClientAddress address,
    String? username,
    String? password,
    String? token,
    required void Function(Client client, String) onError,
    required void Function(Client client) onSuccess,
  }) async {
    Client? client;

    client = Client(
        address: address,
        onError: (error) {
          onError(client!, error.toString());
        }
    );

    try {
      // Throws an error if connection fails
      await client.connect();

      final loginResult = await client.login(
          username: username,
          password: password,
          token: token
      );

      // Throws an error if login fails
      if(loginResult.error != null) {
        throw loginResult.error!;
      }

      await SecureStorage().write("${loginResult.serverId}.token", loginResult.token!);
      await SecureStorage().write("${loginResult.serverId}.userId", loginResult.userId!);
      await SecureStorage().write("${loginResult.serverId}.host", address.host);
      await SecureStorage().write("${loginResult.serverId}.port", address.port.toString());
      ClientManager().addClient(client);
      onSuccess(client);
    } catch (e, stacktrace) {
      client.disconnect();
      onError(client, e.toString() + stacktrace.toString());
    }
  }

  void connect() async {
    setState(() {
      _isConnecting = true;
    });

    await _connect(
      address: ClientAddress(
        host: _serverHostController.text,
        port: 55000,
      ),
      username: _usernameController.text,
      password: _passwordController.text,
      onError: (client, error) {
        setState(() {
          setErrorMessage(error);
          _isConnecting = false;
        });
      },
      onSuccess: (client) {
        setState(() {
          setErrorMessage('');
          _isConnecting = false;
        });

        CurrentClientProvider.of(context, listen: false).selectClient(client);
        context.go('/');
      }
    );
  }

  void _abortConnection() async {
    if(_client != null) {
      await _client!.disconnect();
    }
    setState(() {
      _isConnecting = false;
      setErrorMessage('');
    });
  }

  @override
  Widget build(BuildContext context) {

    if(_errorMessage.isNotEmpty || _isConnecting) {
      return MyScaffold(body: ConnectionWidget(
        client: _client,
        onCancel: _abortConnection,
        errorMessage: _errorMessage,
      ));
    }

     return MyScaffold(body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Container(
               width: 300,
               padding: const EdgeInsets.all(16),
               child: const Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  // Welcome the tester
                   Text('Welcome tester!', style: TextStyle(fontSize: 24)),
                   SizedBox(height: 16),
                   // Notify him about this is unpublished testing version of Talk. His credentials are in email or private message.
                   Text('This is an unpublished testing version of Talk. Your credentials are in email or private message.'),
                 ]
               )
             ),
             Container(
               width: 300,
               decoration: BoxDecoration(
                 border: Border.all(),
                 borderRadius: BorderRadius.circular(8),
                 color: ThemeController.scheme(context).surfaceContainerHigh,
               ),
               padding: const EdgeInsets.all(16),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   // Login form title
                   const Text('Welcome', style: TextStyle(fontSize: 24)),
                   const SizedBox(height: 16),
                   Form(
                       key: _formKey,
                       child: Column(
                         children: [
                           if (kDebugMode)
                             TextFormField(
                               controller: _serverHostController,
                               decoration: const InputDecoration(
                                 labelText: 'Server Host',
                               ),
                               validator: (value) {
                                 if (value == null || value.isEmpty) {
                                   return 'Please enter some text';
                                 }

                                 if (value.length < 3) {
                                   return 'Server host must be at least 3 characters long';
                                 }

                                 return null;
                               },
                             ),
                           TextFormField(
                             controller: _usernameController,
                             decoration: const InputDecoration(
                               labelText: 'Username',
                             ),
                             inputFormatters: [
                               FilteringTextInputFormatter.deny(
                                   RegExp(r'\s')),
                             ],
                             validator: (value) {
                               if (value == null || value.isEmpty) {
                                 return 'Please enter some text';
                               }
             
                               if (value.length < 3) {
                                 return 'Username must be at least 3 characters long';
                               }
             
                               // Check for username regex
                               if(RegExp(r'\s').hasMatch(value)) {
                                 return 'Username cannot contain whitespace';
                               }
             
                               return null;
                             },
                           ),
                           const SizedBox(height: 16),
                           TextFormField(
                             controller: _passwordController,
                             obscureText: true,
                             decoration: const InputDecoration(
                               labelText: 'Password',
                             ),
                             validator: (value) {
                               if (value == null || value.isEmpty) {
                                 return 'Please enter some text';
                               }
             
                               if (value.length < 3) {
                                 return 'Password must be at least 3 characters long';
                               }
             
                               // Check for password regex
                               if(RegExp(r'\s').hasMatch(value)) {
                                 return 'Password cannot contain whitespace';
                               }
             
                               return null;
                             },
                           ),
                         ],
                       )),
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       // Login button
                       ElevatedButton(
                         onPressed: () {
                           if (_formKey.currentState!.validate()) {
                             connect();
                           }
                         },
                         child: const Text('Login'),
                       ),
                       // Register button
                       const Tooltip(
                         message: "Registration is not available in this version of Talk.",
                         child: TextButton(
                           onPressed: null,
                           child: Text('Register'),
                         ),
                         
                       ),
                     ]
                   ),
             
                 ],
               ),
             ),
           ],
         ),
       ],
     ));
  }
}

class ConnectionWidget extends StatelessWidget {
  final Client? client;
  final VoidCallback? onCancel;
  final String errorMessage;
  const ConnectionWidget({super.key, required this.client, required this.onCancel, required this.errorMessage});

  @override
  Widget build(BuildContext context) {

    if(client == null || errorMessage.isNotEmpty) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Oops! Something went wrong.'),
              SelectableText(errorMessage),
              // Add note for copying text
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              )
            ]
        ),
      );
    }

    // Show indication about connecting to server and show error if any
    // Show a button for cancelling the connection
    return ListenableBuilder(
      listenable: client!.connection,
      builder: (context, widget) {

        return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Connecting to server...'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _logger.fine("Cancelled connection to server.");
                    onCancel!();
                  },
                  child: const Text('Cancel'),
                )
              ]
          ),
        );
      }
    );
  }
}