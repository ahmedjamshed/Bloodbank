part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure({this.message});
}

class LoginSuccess extends LoginState {
  final String accessToken;

  LoginSuccess({this.accessToken});
}
