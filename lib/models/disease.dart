import 'package:formz/formz.dart';

enum DiseaseValidationError { invalid }

class Disease extends FormzInput<String, DiseaseValidationError> {
  const Disease.pure() : super.pure('');
  const Disease.dirty([String value = '']) : super.dirty(value);

  @override
  DiseaseValidationError validator(String value) {
    return value != '' ? null : DiseaseValidationError.invalid;
  }
}
