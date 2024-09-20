// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Authentication error: ${error}";

  static String m1(error) => "Login failed: ${error}";

  static String m2(serverHost) => "Welcome ${serverHost}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "loginScreenAuthenticationError": m0,
        "loginScreenCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "loginScreenConnectingToServer":
            MessageLookupByLibrary.simpleMessage("Connecting to server..."),
        "loginScreenConnectionError":
            MessageLookupByLibrary.simpleMessage("Connection error"),
        "loginScreenContinue": MessageLookupByLibrary.simpleMessage("Continue"),
        "loginScreenEmail": MessageLookupByLibrary.simpleMessage("Email"),
        "loginScreenEmailHelperText": MessageLookupByLibrary.simpleMessage(
            "Optional: Set an email for account recovery. Without it, you won\'t be able to recover your account if you lose access."),
        "loginScreenError": MessageLookupByLibrary.simpleMessage("Error"),
        "loginScreenGoBack": MessageLookupByLibrary.simpleMessage("Go back"),
        "loginScreenInvalidEmail":
            MessageLookupByLibrary.simpleMessage("Invalid email"),
        "loginScreenLoggedInSuccessfully":
            MessageLookupByLibrary.simpleMessage("Logged in successfully."),
        "loginScreenLogin": MessageLookupByLibrary.simpleMessage("Login"),
        "loginScreenLoginFailedError": m1,
        "loginScreenOk": MessageLookupByLibrary.simpleMessage("Ok"),
        "loginScreenOopsSomethingWentWrong":
            MessageLookupByLibrary.simpleMessage("Oops! Something went wrong."),
        "loginScreenPassword": MessageLookupByLibrary.simpleMessage("Password"),
        "loginScreenPasswordRequired":
            MessageLookupByLibrary.simpleMessage("Password is required"),
        "loginScreenPasswordsDoNotMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "loginScreenRePassword":
            MessageLookupByLibrary.simpleMessage("Re-Password"),
        "loginScreenRePasswordRequired":
            MessageLookupByLibrary.simpleMessage("Re-Password is required"),
        "loginScreenRegister": MessageLookupByLibrary.simpleMessage("Register"),
        "loginScreenRegistrationIsNotAvailableInThisVersionOfMickle":
            MessageLookupByLibrary.simpleMessage(
                "Registration is not available in this version of Mickle."),
        "loginScreenRegistrationSuccess":
            MessageLookupByLibrary.simpleMessage("Registration successful."),
        "loginScreenServerConnectionError":
            MessageLookupByLibrary.simpleMessage("Server connection error"),
        "loginScreenServerConnectionErrorDetailed":
            MessageLookupByLibrary.simpleMessage(
                "Unable to connect to the server. Please check the server address and your network connection."),
        "loginScreenServerHost":
            MessageLookupByLibrary.simpleMessage("Server Host"),
        "loginScreenServerHostRequired":
            MessageLookupByLibrary.simpleMessage("Server host is required"),
        "loginScreenSuccess": MessageLookupByLibrary.simpleMessage("Success"),
        "loginScreenThisIsAnUnpublishedTestingVersionOfMickleYourCredentials":
            MessageLookupByLibrary.simpleMessage(
                "This is an unpublished testing version of Mickle. Your credentials are in email or private message."),
        "loginScreenUnexpectedError":
            MessageLookupByLibrary.simpleMessage("Unexpected error"),
        "loginScreenUnexpectedErrorDetailed": MessageLookupByLibrary.simpleMessage(
            "An unexpected error occurred. Please try again later or contact support if the issue persists."),
        "loginScreenUsername": MessageLookupByLibrary.simpleMessage("Username"),
        "loginScreenUsernameRequired":
            MessageLookupByLibrary.simpleMessage("Username is required"),
        "loginScreenValidatorsPasswordCannotContainWhitespace":
            MessageLookupByLibrary.simpleMessage(
                "Password cannot contain whitespace"),
        "loginScreenValidatorsPasswordMustBeAtLeast3CharactersLong":
            MessageLookupByLibrary.simpleMessage(
                "Password must be at least 3 characters long"),
        "loginScreenValidatorsPleaseEnterSomeText":
            MessageLookupByLibrary.simpleMessage("Please enter some text"),
        "loginScreenValidatorsServerHostMustBeAtLeast3CharactersLong":
            MessageLookupByLibrary.simpleMessage(
                "Server host must be at least 3 characters long"),
        "loginScreenValidatorsUsernameCannotContainWhitespace":
            MessageLookupByLibrary.simpleMessage(
                "Username cannot contain whitespace"),
        "loginScreenValidatorsUsernameMustBeAtLeast3CharactersLong":
            MessageLookupByLibrary.simpleMessage(
                "Username must be at least 3 characters long"),
        "loginScreenWelcome": m2,
        "loginScreenWelcomeTester":
            MessageLookupByLibrary.simpleMessage("Welcome tester!")
      };
}
