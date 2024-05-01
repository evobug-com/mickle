// Login screen will be a simple form with email and password fields.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/connection/connection.dart';
import 'package:talk/core/connection/session_manager.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  Connection? _connectingTo;

  @override
  Widget build(BuildContext context) {

    if(_connectingTo != null) {
      return ConnectionWidget(
        connection: _connectingTo!,
        errorMessage: errorMessage,
        onCancel: () {
          setState(() {
            SessionManager().removeSession(_connectingTo!.serverAddress);
            _connectingTo = null;
          });
        }
      );
    }

    // In the centre of screen there will be two boxes
    // Left box will contain some text
    // Right box will contain login form

     return Column(
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
                 color: Theme.of(context).extension<MyTheme>()!.sidebarSurface,
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
                           TextFormField(
                             controller: usernameController,
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
                             controller: passwordController,
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
                            setState(() {
                              _connectingTo = SessionManager().addSession("localhost", usernameController.text, passwordController.text, (error) {
                                errorMessage.value = error;
                              }, () {
                                CurrentSession().connection = _connectingTo;
                                context.go('/');
                              });
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
     );
  }
}

class ConnectionWidget extends StatelessWidget {
  final Connection connection;
  final VoidCallback? onCancel;
  final ValueNotifier<String?> errorMessage;
  const ConnectionWidget({super.key, required this.connection, required this.onCancel, required this.errorMessage});

  @override
  Widget build(BuildContext context) {

    // Show indication about connecting to server and show error if any
    // Show a button for cancelling the connection
    return ListenableBuilder(
      listenable: connection,
      builder: (context, widget) {

        if(errorMessage.value != null) {
          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Oops! Something went wrong.'),
                  SelectableText('${errorMessage.value}'),
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
                    print("Cancelled connection to server.");
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