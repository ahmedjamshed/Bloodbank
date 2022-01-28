import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/tabNavigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  ApiClient apiClient;
  LoginBloc({@required this.apiClient}) : super(LoginInitial());
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LogEvent) {
      yield* _mapLogToState(
        event.email,
        event.password,
        event.context,
        event.chatApi,
        event.yourId,
      );
    }
  }

  Stream<LoginState> _mapLogToState(
    String email,
    String password,
    BuildContext context,
    ChatApiClient chatApi,
    String yourId,
  ) async* {
    yield LoginLoading();
    try {
      final SharedPreferences prefs = await _prefs;
      final String fcmToken = prefs.getString("fcmToken");
      final response = await apiClient.signIn(email, password, fcmToken);
      if (response is String) {
        showToast(response);
        yield LoginFailure(message: response);
      } else {
        prefs.setString("auth", response['signIn']['accessToken']);
        print(response['signIn']['accessToken']);
        apiClient = ApiClient().create(response['signIn']['accessToken']);
        yield LoginSuccess(accessToken: response['signIn']['accessToken']);
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            settings: RouteSettings(name: TabNavigator.tabNavigator),
            builder: (context) => TabNavigator(
              apiClient: apiClient,
              chatApi: chatApi,
              yourId: yourId,
            ),
          ),
        )
            .then((value) {
          apiClient = ApiClient().create("");
        });
      }
    } catch (_) {
      showToast(" Network error ");
      yield LoginFailure(message: "");
    }
  }
}
