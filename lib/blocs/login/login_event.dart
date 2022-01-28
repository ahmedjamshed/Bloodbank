part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LogEvent extends LoginEvent {
  final BuildContext context;
  final ChatApiClient chatApi;
  final String yourId;
  final String email;
  final String password;

  LogEvent({
    @required this.email,
    @required this.chatApi,
    @required this.yourId,
    @required this.password,
    this.context,
  });
}
