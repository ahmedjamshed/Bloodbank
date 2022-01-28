import 'package:formz/formz.dart';

enum PhoneValidationError { invalid }

class Phone extends FormzInput<String, PhoneValidationError> {
  const Phone.pure() : super.pure('');
  const Phone.dirty([String value = '']) : super.dirty(value);

  static final _phoneRegex = RegExp(
    r'^(?:\+92|0)3[0-4][0-9]\d{7}$',
  );

  @override
  PhoneValidationError validator(String value) {
    return _phoneRegex.hasMatch(value) ? null : PhoneValidationError.invalid;
  }
}
