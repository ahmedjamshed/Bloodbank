part of 'register_bloc.dart';

@immutable
class RegisterState extends Equatable {
  RegisterState({
    this.name = const Name.pure(),
    this.lName = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.check = false,
    this.status = FormzStatus.pure,
    this.loading = false,
  });

  final Name name;
  final Name lName;
  final Email email;
  final Password password;
  final bool check;
  final FormzStatus status;
  final bool loading;

  RegisterState copyWith({
    Name name,
    Name lName,
    Email email,
    Password password,
    bool check,
    FormzStatus status,
    bool loading,
  }) {
    return RegisterState(
        name: name ?? this.name,
        lName: lName ?? this.lName,
        email: email ?? this.email,
        password: password ?? this.password,
        check: check ?? this.check,
        status: status ?? this.status,
        loading: loading ?? this.loading);
  }

  @override
  List<Object> get props =>
      [name, lName, email, password, check, status, loading];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String message;

  RegisterFailure({this.message});
}

class RegisterSuccess extends RegisterState {
  final String accessToken;

  RegisterSuccess({this.accessToken});
}
