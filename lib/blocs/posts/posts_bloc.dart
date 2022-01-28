import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/blood_conversion.dart';
import 'package:bloodbank/models/disease.dart';
import 'package:bloodbank/models/name.dart';
import 'package:bloodbank/models/post.dart';
import 'package:bloodbank/models/profile.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/screens/loginScreen.dart';
import 'package:bloodbank/screens/tabNavigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final ApiClient apiClient;
  PostsBloc({this.apiClient}) : super(PostsInitial());
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Stream<Transition<PostsEvent, PostsState>> transformEvents(
    Stream<PostsEvent> events,
    TransitionFunction<PostsEvent, PostsState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<PostsState> mapEventToState(
    PostsEvent event,
  ) async* {
    // final currentState = state;
    if (event is NameChanged) {
      final name = Name.dirty(event.name);
      yield state.copyWith(
        name: name,
        status: Formz.validate([state.disease, name]),
      );
    } else if (event is DiseaseChanged) {
      final disease = Disease.dirty(event.disease);
      yield state.copyWith(
        disease: disease,
        status: Formz.validate([state.name, disease]),
      );
    } else if (event is CheckChanged) {
      final check = event.check;
      yield state.copyWith(
        check: check,
        status: Formz.validate([state.name, state.disease]),
      );
    } else if (event is FetchMatchedPosts) {
      yield* _mapFetchMatchedPostsToState(
        event.city,
        event.bloodType,
        event.donationType,
        event.userType,
        event.profileLevel,
        event.filter,
        event.refresh,
        event.context,
        event.yourId,
        event.chatApi,
      );
    } else if (event is CreatePost) {
      yield* _mapCreatPostToState(
        event.age,
        event.bloodValue,
        event.bloodType,
        event.city,
        event.addressLat,
        event.addressLon,
        event.hospLat,
        event.hospLon,
        event.userId,
        event.context,
      );
    }
  }

  Stream<PostsState> _mapFetchMatchedPostsToState(
    String city,
    String bloodType,
    String donationType,
    String userType,
    String profileLevel,
    bool filter,
    bool refresh,
    BuildContext context,
    String yourId,
    ChatApiClient chatApi,
  ) async* {
    final currentState = state;
    print(city);
    print(bloodType);
    print(donationType);
    print(userType);
    print(profileLevel);
    print(filter);
    print(refresh);
    try {
      if (currentState is PostsInitial) {
        final response = await apiClient.getPosts(
          city,
          bloodType,
          donationType,
          userType,
          profileLevel,
          0,
          10,
          filter,
        );
        if (response is String) {
          showToast(response);
          yield PostsFailure(message: response);
          if (response == "You must be authorized.") {
            final SharedPreferences prefs = await _prefs;
            prefs.setString("auth", null);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                settings: RouteSettings(name: LoginScreen.loginScreen),
                builder: (context) => LoginScreen(
                  apiClient: ApiClient().create(""),
                  chatApi: chatApi,
                  yourId: yourId,
                ),
              ),
            );
          }
        } else {
          List<Post> posts = [];
          var tempPosts = response['matchedPosts'] as List;
          if (tempPosts.length > 0) {
            for (var post in tempPosts) {
              String val = convertBlood(post['bloodType']);
              posts.add(
                Post(
                  userId: post['userID'],
                  name: post['name'],
                  bloodType: val,
                  disease: post['disease'],
                  city: post['city'],
                  user: User(
                    fName: post['user']['firstName'],
                    lName: post['user']['lastName'],
                    profileLevel: post['user']['profileLevel'].toString(),
                    phone: post['user']['profile']['level']['phone']['number'],
                    profile: Profile(
                      picture: post['user']['profile']['profilePic'],
                      address: post['user']['profile'] == null
                          ? "Test address"
                          : post['user']['profile']['address'],
                    ),
                  ),
                ),
              );
            }
          }
          yield PostsSuccess(
            posts: posts,
            hasReachedMax: tempPosts.length < 10 ? true : false,
          );
          return;
        }
      }
      if (currentState is PostsSuccess) {
        if (refresh) {
          yield currentState.copyWith(hasReachedMax: false);
        }
        final response = await apiClient.getPosts(
          city,
          bloodType,
          donationType,
          userType,
          profileLevel,
          !refresh ? currentState.posts.length : 0,
          !refresh ? currentState.posts.length + 10 : 10,
          filter,
        );
        if (response is String) {
          showToast(response);
          yield PostsFailure(message: response);
        } else {
          List<Post> posts = [];
          var tempPosts = response['matchedPosts'] as List;
          print(tempPosts.length);
          if (tempPosts.length > 0) {
            for (var post in tempPosts) {
              String val = convertBlood(post['bloodType']);
              posts.add(
                Post(
                  userId: post['userID'],
                  name: post['name'],
                  bloodType: val,
                  disease: post['disease'],
                  city: post['city'],
                  user: User(
                    fName: post['user']['firstName'],
                    lName: post['user']['lastName'],
                    profileLevel: post['user']['profileLevel'].toString(),
                    phone: post['user']['profile']['level']['phone']['number'],
                    profile: Profile(
                      picture: post['user']['profile']['profilePic'],
                      address: post['user']['profile'] == null
                          ? "Test address"
                          : post['user']['profile']['address'],
                    ),
                  ),
                ),
              );
            }
          }
          yield PostsLoading();
          yield (posts.isEmpty && refresh == false)
              ? currentState.copyWith(hasReachedMax: true)
              : PostsSuccess(
                  posts: refresh ? posts : currentState.posts + posts,
                  hasReachedMax: false,
                );
        }
      }
    } catch (_) {
      showToast("Something went wrong.");
      yield PostsFailure(message: "Something went wrong.");
    }
  }

  Stream<PostsState> _mapCreatPostToState(
    int age,
    String bloodValue,
    String bloodType,
    String city,
    double addressLat,
    double addressLon,
    double hospLat,
    double hospLon,
    String userId,
    BuildContext context,
  ) async* {
    yield PostsLoading();
    try {
      if (state.status.isValidated && state.check == true) {
        final response = await apiClient.createNewPost(
          state.name.value,
          age,
          state.disease.value,
          bloodValue,
          bloodType,
          city,
          addressLat,
          addressLon,
          hospLat,
          hospLon,
          userId,
        );
        if (response is String) {
          yield state.copyWith(
            name: state.name,
            check: state.check,
            status: Formz.validate([
              state.name,
              state.disease,
            ]),
          );
          showToast(response);
          yield PostsFailure(message: response);
        } else {
          yield PostsSuccess();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              settings: RouteSettings(name: TabNavigator.tabNavigator),
              builder: (context) => TabNavigator(
                apiClient: apiClient,
                // <-- yourId here
              ),
            ),
          );
        }
      } else {
        if (state.name.invalid ||
            state.name.value == "" ||
            !state.name.value.contains(" ")) {
          showToast("Name should contain one space: John Doe");
        } else if (state.disease.invalid || state.disease.value == "") {
          showToast("Invalid disease!");
        } else if (state.check == false) {
          showToast("Please agree that all details are correct.");
        }
        yield state.copyWith(
          name: state.name,
          check: state.check,
          status: Formz.validate([
            state.name,
            state.disease,
          ]),
        );
      }
    } catch (_) {
      print(_);
      yield state.copyWith(
        name: state.name,
        check: state.check,
        status: Formz.validate([
          state.name,
          state.disease,
        ]),
      );
      showToast("Something went wrong");
      yield PostsFailure(message: "Something went wrong.");
    }
  }
}
