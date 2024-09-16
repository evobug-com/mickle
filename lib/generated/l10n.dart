// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Logged in successfully.`
  String get loginScreenLoggedInSuccessfully {
    return Intl.message(
      'Logged in successfully.',
      name: 'loginScreenLoggedInSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Login failed: {error}`
  String loginScreenLoginFailedError(Object error) {
    return Intl.message(
      'Login failed: $error',
      name: 'loginScreenLoginFailedError',
      desc: '',
      args: [error],
    );
  }

  /// `Oops! Something went wrong.`
  String get loginScreenOopsSomethingWentWrong {
    return Intl.message(
      'Oops! Something went wrong.',
      name: 'loginScreenOopsSomethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Go back`
  String get loginScreenGoBack {
    return Intl.message(
      'Go back',
      name: 'loginScreenGoBack',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to server...`
  String get loginScreenConnectingToServer {
    return Intl.message(
      'Connecting to server...',
      name: 'loginScreenConnectingToServer',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get loginScreenCancel {
    return Intl.message(
      'Cancel',
      name: 'loginScreenCancel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter some text`
  String get loginScreenValidatorsPleaseEnterSomeText {
    return Intl.message(
      'Please enter some text',
      name: 'loginScreenValidatorsPleaseEnterSomeText',
      desc: '',
      args: [],
    );
  }

  /// `Server host must be at least 3 characters long`
  String get loginScreenValidatorsServerHostMustBeAtLeast3CharactersLong {
    return Intl.message(
      'Server host must be at least 3 characters long',
      name: 'loginScreenValidatorsServerHostMustBeAtLeast3CharactersLong',
      desc: '',
      args: [],
    );
  }

  /// `Username must be at least 3 characters long`
  String get loginScreenValidatorsUsernameMustBeAtLeast3CharactersLong {
    return Intl.message(
      'Username must be at least 3 characters long',
      name: 'loginScreenValidatorsUsernameMustBeAtLeast3CharactersLong',
      desc: '',
      args: [],
    );
  }

  /// `Username cannot contain whitespace`
  String get loginScreenValidatorsUsernameCannotContainWhitespace {
    return Intl.message(
      'Username cannot contain whitespace',
      name: 'loginScreenValidatorsUsernameCannotContainWhitespace',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 3 characters long`
  String get loginScreenValidatorsPasswordMustBeAtLeast3CharactersLong {
    return Intl.message(
      'Password must be at least 3 characters long',
      name: 'loginScreenValidatorsPasswordMustBeAtLeast3CharactersLong',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot contain whitespace`
  String get loginScreenValidatorsPasswordCannotContainWhitespace {
    return Intl.message(
      'Password cannot contain whitespace',
      name: 'loginScreenValidatorsPasswordCannotContainWhitespace',
      desc: '',
      args: [],
    );
  }

  /// `Welcome tester!`
  String get loginScreenWelcomeTester {
    return Intl.message(
      'Welcome tester!',
      name: 'loginScreenWelcomeTester',
      desc: '',
      args: [],
    );
  }

  /// `This is an unpublished testing version of Mickle. Your credentials are in email or private message.`
  String
      get loginScreenThisIsAnUnpublishedTestingVersionOfMickleYourCredentials {
    return Intl.message(
      'This is an unpublished testing version of Mickle. Your credentials are in email or private message.',
      name:
          'loginScreenThisIsAnUnpublishedTestingVersionOfMickleYourCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get loginScreenWelcome {
    return Intl.message(
      'Welcome',
      name: 'loginScreenWelcome',
      desc: '',
      args: [],
    );
  }

  /// `Server Host`
  String get loginScreenServerHost {
    return Intl.message(
      'Server Host',
      name: 'loginScreenServerHost',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get loginScreenUsername {
    return Intl.message(
      'Username',
      name: 'loginScreenUsername',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get loginScreenPassword {
    return Intl.message(
      'Password',
      name: 'loginScreenPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginScreenLogin {
    return Intl.message(
      'Login',
      name: 'loginScreenLogin',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get loginScreenRegister {
    return Intl.message(
      'Register',
      name: 'loginScreenRegister',
      desc: '',
      args: [],
    );
  }

  /// `Registration is not available in this version of Mickle.`
  String get loginScreenRegistrationIsNotAvailableInThisVersionOfMickle {
    return Intl.message(
      'Registration is not available in this version of Mickle.',
      name: 'loginScreenRegistrationIsNotAvailableInThisVersionOfMickle',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
