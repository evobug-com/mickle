
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';

import '../core/connection/client.dart';
import '../core/notifiers/theme_controller.dart';
import '../layout/my_scaffold.dart';
import '../services/auth_service.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _serverHostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _abortConnection() async {
    final auth = AuthService();
    if(auth.currentLoggingClient != null) {
      await auth.abortLogin();

      if(auth.errorMessage != null) {
        auth.errorMessage = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
     return ListenableBuilder(
       listenable: auth,
       builder: (context, widget) {
         if(auth.errorMessage != null || auth.isLoading) {
           return MyScaffold(body: ConnectionWidget(
             client: auth.currentLoggingClient,
             onCancel: _abortConnection,
             errorMessage: auth.errorMessage,
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
                                 auth.login(
                                     context,
                                     address: ClientAddress(
                                         host: _serverHostController.text,
                                         port: 3000
                                     ),
                                     username: _usernameController.text,
                                     password: _passwordController.text
                                 ).then((client) {
                                   if(client != null) {
                                     CurrentClientProvider().selectClient(client);
                                     _logger.fine("Logged in successfully.");
                                   }
                                 }).catchError((e) {
                                   _logger.severe("Login failed: $e");
                                 });
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
     );
  }
}

class ConnectionWidget extends StatelessWidget {
  final Client? client;
  final VoidCallback? onCancel;
  final String? errorMessage;
  const ConnectionWidget({super.key, required this.client, required this.onCancel, required this.errorMessage});

  @override
  Widget build(BuildContext context) {

    if(client == null || errorMessage != null) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Oops! Something went wrong.'),
              SelectableText(errorMessage!),
              // Add note for copying text
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCancel,
                child: const Text('Go back'),
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