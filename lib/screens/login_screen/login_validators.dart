class Validators {
  static String? serverHost(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    if (value.length < 3) {
      return 'Server host must be at least 3 characters long';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (RegExp(r'\s').hasMatch(value)) {
      return 'Username cannot contain whitespace';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    if (value.length < 3) {
      return 'Password must be at least 3 characters long';
    }
    if (RegExp(r'\s').hasMatch(value)) {
      return 'Password cannot contain whitespace';
    }
    return null;
  }
}