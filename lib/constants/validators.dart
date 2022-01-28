class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );
  static final RegExp _phoneRegExp = RegExp(
    r'^(?:\+92|0)3[0-4][0-9]\d{7}$',
  );

  static isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static isValidPhone(String phone) {
    return _phoneRegExp.hasMatch(phone);
  }

  static isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }
}
