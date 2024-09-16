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

  static String m0(error) => "Login failed: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "loginScreenCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "loginScreenConnectingToServer":
            MessageLookupByLibrary.simpleMessage("Connecting to server..."),
        "loginScreenGoBack": MessageLookupByLibrary.simpleMessage("Go back"),
        "loginScreenLoggedInSuccessfully":
            MessageLookupByLibrary.simpleMessage("Logged in successfully."),
        "loginScreenLogin": MessageLookupByLibrary.simpleMessage("Login"),
        "loginScreenLoginFailedError": m0,
        "loginScreenOopsSomethingWentWrong":
            MessageLookupByLibrary.simpleMessage("Oops! Something went wrong."),
        "loginScreenPassword": MessageLookupByLibrary.simpleMessage("Password"),
        "loginScreenRegister": MessageLookupByLibrary.simpleMessage("Register"),
        "loginScreenRegistrationIsNotAvailableInThisVersionOfMickle":
            MessageLookupByLibrary.simpleMessage(
                "Registration is not available in this version of Mickle."),
        "loginScreenServerHost":
            MessageLookupByLibrary.simpleMessage("Server Host"),
        "loginScreenThisIsAnUnpublishedTestingVersionOfMickleYourCredentials":
            MessageLookupByLibrary.simpleMessage(
                "This is an unpublished testing version of Mickle. Your credentials are in email or private message."),
        "loginScreenUsername": MessageLookupByLibrary.simpleMessage("Username"),
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
        "loginScreenWelcome": MessageLookupByLibrary.simpleMessage("Welcome"),
        "loginScreenWelcomeTester":
            MessageLookupByLibrary.simpleMessage("Welcome tester!")
      };
}
