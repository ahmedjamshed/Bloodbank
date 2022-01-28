import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/address.dart';
import 'package:bloodbank/models/message_data.dart';
import 'package:bloodbank/models/phone.dart';
import 'package:bloodbank/models/profile.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/screens/loginScreen.dart';
import 'package:bloodbank/screens/tabNavigator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiClient apiClient;
  ProfileBloc({this.apiClient}) : super(ProfileInitial());
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void onTransition(Transition<ProfileEvent, ProfileState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<Transition<ProfileEvent, ProfileState>> transformEvents(
    Stream<ProfileEvent> events,
    TransitionFunction<ProfileEvent, ProfileState> transitionFn,
  ) {
    final debounced = events
        .where((event) => event is! UpdateProfile)
        .debounceTime(const Duration(milliseconds: 300));
    return events
        .where((event) => event is UpdateProfile)
        .mergeWith([debounced]).switchMap(transitionFn);
  }

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is PhoneChanged) {
      final phone = Phone.dirty(event.phone);
      yield state.copyWith(
        phone: phone,
        status: Formz.validate([phone, state.address]),
      );
    } else if (event is AddressChanged) {
      final address = Address.dirty(event.address);
      yield state.copyWith(
        address: address,
        status: Formz.validate([state.phone, address]),
      );
    } else if (event is UpdateProfile) {
      yield* _mapUpdateProfileToState(
        event.gender,
        event.age,
        event.city,
        event.bloodType,
        event.reason,
        event.context,
        event.chatApi,
        event.picture,
      );
    } else if (event is GetUser) {
      yield* _mapGetUserToState(event.context);
    } else if (event is UpdatePhone) {
      yield* _mapUpdatePhoneToState(event.phone);
    } else if (event is UpdateCnic) {
      yield* _mapUpdateCnicToState(event.cnic);
    } else if (event is UpdateMedical) {
      yield* _mapUpdateMedicalToState(event.medical);
    } else if (event is UpdateReason) {
      yield* _mapUpdateReasonToState(event.reason, event.context);
    }
  }

  Stream<ProfileState> _mapUpdatePhoneToState(String phone) async* {
    yield ProfileLoading();
    try {
      final response = await apiClient.updateNumber(phone);
      if (response is String) {
        showToast(response);
        yield ProfileFailure(message: response);
      } else {
        showToast("Phone has been added Successfully!");
        yield ProfileSuccess();
      }
    } catch (_) {
      yield ProfileFailure();
    }
  }

  Stream<ProfileState> _mapUpdateCnicToState(String cnic) async* {
    yield ProfileLoading();
    try {
      final response = await apiClient.updateCNIC(cnic);
      if (response is String) {
        showToast(response);
        yield ProfileFailure(message: response);
      } else {
        showToast("CNIC has been added Successfully!");
        yield ProfileSuccess();
      }
    } catch (_) {
      yield ProfileFailure();
    }
  }

  Stream<ProfileState> _mapUpdateMedicalToState(String medical) async* {
    yield ProfileLoading();
    try {
      final response = await apiClient.updateMedicalReport(medical);
      if (response is String) {
        showToast(response);
        yield ProfileFailure(message: response);
      } else {
        showToast("Medical Report has been added Successfully!");
        yield ProfileSuccess();
      }
    } catch (_) {
      yield ProfileFailure();
    }
  }

  Stream<ProfileState> _mapUpdateReasonToState(
      String reason, BuildContext context) async* {
    yield ProfileLoading();
    try {
      final response = await apiClient.updateReason(reason);
      if (response is String) {
        showToast(response);
        yield ProfileFailure(message: response);
      } else {
        yield* _mapGetUserToState(context);
      }
    } catch (_) {
      yield ProfileFailure();
    }
  }

  Stream<ProfileState> _mapGetUserToState(BuildContext context) async* {
    yield ProfileLoading();
    try {
      final SharedPreferences prefs = await _prefs;
      final response = await apiClient.getUser();
      if (response is String) {
        showToast(response);
        yield ProfileFailure(message: response);
        if (response == "You must be authorized.") {
          prefs.setString("auth", null);
          Navigator.pushReplacementNamed(context, LoginScreen.loginScreen);
        }
      } else {
        var tempUser = response['user'];
        prefs.setString("userId", tempUser['_id']);
        Provider.of<ChatData>(context, listen: false).setId(tempUser['_id']);
        var tempProfile = response['user']['profile'];
        final User user = User(
          id: tempUser['_id'],
          email: tempUser['email'],
          fName: tempUser['firstName'],
          lName: tempUser['lastName'],
          locale: tempUser['locale'],
          profileLevel: tempUser['profileLevel'].toString(),
          phone: tempProfile['level']['phone']['number'],
          phoneVerified: tempProfile['level']['phone']['verified'],
          cnic: tempProfile['level']['cnic']['imageUrl'] == null
              ? ""
              : tempProfile['level']['cnic']['imageUrl'],
          cnicVerified: tempProfile['level']['cnic']['verified'],
          medical:
              tempProfile['level']['medicalReport']['medicalReportUrl'] == null
                  ? ""
                  : tempProfile['level']['medicalReport']['medicalReportUrl'],
          medicalVerified: tempProfile['level']['medicalReport']['verified'],
          profile: Profile(
            picture: tempProfile['profilePic'],
            bloodType: tempProfile['bloodType'],
            age: tempProfile['age'],
            address: tempProfile['address'],
            city: tempProfile['city'],
            gender: tempProfile['gender'],
            reason: tempProfile['reason'],
          ),
        );
        yield ProfileSuccess(user: user);
      }
    } catch (_) {
      showToast("Something went wrong.");
      yield ProfileFailure(message: "Something went wrong.");
    }
  }

  Stream<ProfileState> _mapUpdateProfileToState(
    String gender,
    int age,
    String city,
    String bloodType,
    String reason,
    BuildContext context,
    ChatApiClient chatApi,
    String picture,
  ) async* {
    yield ProfileLoading();
    try {
      if (state.status.isValidated) {
        final response = await apiClient.updateProfile(
            gender,
            age,
            state.address.value,
            city,
            state.phone.value,
            reason,
            picture,
            bloodType);
        if (response is String) {
          showToast(response);
          yield ProfileFailure(message: response);
          yield state.copyWith(
            phone: state.phone,
            address: state.address,
            status: Formz.validate([
              state.phone,
              state.address,
            ]),
          );
        } else {
          yield ProfileSuccess();
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: RouteSettings(name: TabNavigator.tabNavigator),
              builder: (context) => TabNavigator(
                apiClient: apiClient,
                chatApi: chatApi,
              ),
            ),
          );
        }
      } else {
        if (state.phone.invalid || state.phone.value == "") {
          showToast("Invalid phone!");
        } else if (state.address.invalid || state.address.value == "") {
          showToast("Invalid address!");
        }
        yield state.copyWith(
          phone: state.phone,
          address: state.address,
          status: Formz.validate([
            state.phone,
            state.address,
          ]),
        );
      }
    } catch (_) {
      showToast("Something went wrong.");
      yield ProfileFailure(message: "Something went wrong.");
      yield state.copyWith(
        phone: state.phone,
        address: state.address,
        status: Formz.validate([
          state.phone,
          state.address,
        ]),
      );
    }
  }
}
