import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/email.dart';
import 'package:bloodbank/models/name.dart';
import 'package:bloodbank/models/password.dart';
import 'package:bloodbank/screens/moreDetailScreen.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  ApiClient apiClient;
  ChatApiClient chatApi;
  RegisterBloc({
    @required this.apiClient,
    @required this.chatApi,
  }) : super(RegisterInitial());
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void onTransition(Transition<RegisterEvent, RegisterState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<Transition<RegisterEvent, RegisterState>> transformEvents(
    Stream<RegisterEvent> events,
    TransitionFunction<RegisterEvent, RegisterState> transitionFn,
  ) {
    final debounced = events
        .where((event) => event is! SignUpEvent)
        .debounceTime(const Duration(milliseconds: 300));
    return events
        .where((event) => event is SignUpEvent)
        .mergeWith([debounced]).switchMap(transitionFn);
  }

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EmailChanged) {
      final email = Email.dirty(event.email);
      yield state.copyWith(
        email: email,
        status:
            Formz.validate([email, state.password, state.lName, state.name]),
      );
    } else if (event is PasswordChanged) {
      final password = Password.dirty(event.password);
      yield state.copyWith(
        password: password,
        status:
            Formz.validate([state.email, password, state.lName, state.name]),
      );
    } else if (event is NameChanged) {
      final name = Name.dirty(event.name);
      yield state.copyWith(
        name: name,
        status:
            Formz.validate([state.email, state.password, state.lName, name]),
      );
    } else if (event is LNameChanged) {
      final lName = Name.dirty(event.lName);
      yield state.copyWith(
        lName: lName,
        status:
            Formz.validate([state.email, state.password, state.name, lName]),
      );
    } else if (event is CheckChanged) {
      final check = event.check;
      yield state.copyWith(
          check: check,
          status: Formz.validate(
              [state.email, state.password, state.lName, state.name]));
    } else if (event is SignUpEvent) {
      yield* _mapSignUpToState(
        event.context,
        event.firebaseMessaging,
      );
    }
  }

  Stream<RegisterState> _mapSignUpToState(
    BuildContext context,
    FirebaseMessaging firebaseMessaging,
  ) async* {
    yield state.copyWith(
        name: state.name,
        lName: state.lName,
        email: state.email,
        password: state.password,
        check: state.check,
        loading: true,
        status: Formz.validate([
          state.email,
          state.password,
          state.name,
          state.lName,
        ]));
    try {
      if (state.status.isValidated && state.check == true) {
        String tempName = state.name.value;
        String tempLName = state.lName.value;
        String tempEmail = state.email.value;
        String tempPassword = state.password.value;
        final SharedPreferences prefs = await _prefs;
        final String fcmToken = prefs.getString("fcmToken");
        final response = await apiClient.signUp(
          tempName,
          tempLName,
          tempEmail,
          tempPassword,
          fcmToken,
        );
        if (response is String) {
          showToast(response);
          yield state.copyWith(
              name: state.name,
              lName: state.lName,
              email: state.email,
              password: state.password,
              check: state.check,
              loading: false,
              status: Formz.validate([
                state.email,
                state.password,
                state.name,
                state.lName,
              ]));
        } else {
          prefs.setString("auth", response['signUp']['accessToken']);
          prefs.setString("blood_val", "blood");
          prefs.setString("plasma_val", "plasma");
          prefs.setString("platelets_val", "platelets");
          print(response['signUp']['accessToken']);
          apiClient = ApiClient().create(response['signUp']['accessToken']);
          yield RegisterSuccess(accessToken: response['signUp']['accessToken']);
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: RouteSettings(name: MoreDetailScreen.moreDetailScreen),
              builder: (context) => MoreDetailScreen(
                apiClient: apiClient,
                chatApi: chatApi,
                firebaseMessaging: firebaseMessaging,
              ),
            ),
          );
        }
      } else {
        print(state.lName.value);
        if (state.name.invalid || state.name.value == "") {
          showToast("First name is required");
        } else if (state.lName.invalid || state.lName.value == "") {
          showToast("Last name is required");
        } else if (state.email.invalid || state.email.value == "") {
          if (state.email.invalid)
            showToast("Invalid email format!");
          else
            showToast("Email is required!");
        } else if (state.password.invalid || state.password.value == "") {
          if (state.password.value == "")
            showToast("Password is required!");
          else
            showToast(
                "Password should contain at least 8 characters with minimum one digit.");
        } else if (state.check == false) {
          showToast("Please agree to the terms and conditions.");
        }
        yield state.copyWith(
            name: state.name,
            lName: state.lName,
            email: state.email,
            password: state.password,
            check: state.check,
            loading: false,
            status: Formz.validate([
              state.email,
              state.password,
              state.name,
              state.lName,
            ]));
      }
    } catch (_) {
      yield state.copyWith(
          name: state.name,
          lName: state.lName,
          email: state.email,
          password: state.password,
          check: state.check,
          loading: false,
          status: Formz.validate([
            state.email,
            state.password,
            state.name,
            state.lName,
          ]));
      showToast("Something went wrong.");
    }
  }
}
