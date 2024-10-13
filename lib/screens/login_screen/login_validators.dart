import 'package:flutter/material.dart';
import 'package:mickle/generated/l10n.dart';

class Validators {
  static FormFieldValidator<String?> serverHost(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return S
            .of(context)
            .loginScreenValidatorsPleaseEnterSomeText;
      }
      if (value.length < 3) {
        return S
            .of(context)
            .loginScreenValidatorsServerHostMustBeAtLeast3CharactersLong;
      }
      return null;
    };
  }

  static username(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return S.of(context).loginScreenValidatorsPleaseEnterSomeText;
      }
      if (value.length < 3) {
        return S.of(context).loginScreenValidatorsUsernameMustBeAtLeast3CharactersLong;
      }
      if (RegExp(r'\s').hasMatch(value)) {
        return S.of(context).loginScreenValidatorsUsernameCannotContainWhitespace;
      }
      return null;
    };
  }

  static FormFieldValidator<String?> password(BuildContext context) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return S
            .of(context)
            .loginScreenValidatorsPleaseEnterSomeText;
      }
      if (value.length < 3) {
        return S
            .of(context)
            .loginScreenValidatorsPasswordMustBeAtLeast3CharactersLong;
      }
      if (RegExp(r'\s').hasMatch(value)) {
        return S
            .of(context)
            .loginScreenValidatorsPasswordCannotContainWhitespace;
      }
      return null;
    };
  }
}