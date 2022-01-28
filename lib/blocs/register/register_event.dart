part of 'register_bloc.dart';

@immutable
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class NameChanged extends RegisterEvent {
  const NameChanged({@required this.name});

  final String name;

  @override
  List<Object> get props => [name];
}

class LNameChanged extends RegisterEvent {
  final String lName;
  const LNameChanged({@required this.lName});

  @override
  List<Object> get props => [lName];
}

class EmailChanged extends RegisterEvent {
  const EmailChanged({@required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends RegisterEvent {
  const PasswordChanged({@required this.password});

  final String password;

  @override
  List<Object> get props => [password];
}

class CheckChanged extends RegisterEvent {
  const CheckChanged({@required this.check});

  final bool check;

  @override
  List<Object> get props => [check];
}

class SignUpEvent extends RegisterEvent {
  final BuildContext context;
  final FirebaseMessaging firebaseMessaging;
  SignUpEvent({
    this.context,
    this.firebaseMessaging,
  });

  @override
  List<Object> get props => [context];
}
