part of 'posts_bloc.dart';

@immutable
abstract class PostsEvent {}

class NameChanged extends PostsEvent {
  NameChanged({@required this.name});

  final String name;

  List<Object> get props => [name];
}

class DiseaseChanged extends PostsEvent {
  DiseaseChanged({@required this.disease});

  final String disease;

  List<Object> get props => [disease];
}

class CheckChanged extends PostsEvent {
  CheckChanged({@required this.check});

  final bool check;

  List<Object> get props => [check];
}

class FetchMatchedPosts extends PostsEvent {
  final String city;
  final String bloodType;
  final String userType;
  final String donationType;
  final String profileLevel;
  final bool filter;
  final bool refresh;
  final BuildContext context;
  final ChatApiClient chatApi;
  final String yourId;

  FetchMatchedPosts({
    this.city,
    this.bloodType,
    this.userType,
    this.donationType,
    this.profileLevel,
    this.filter,
    this.refresh,
    this.context,
    this.chatApi,
    this.yourId,
  });
}

class CreatePost extends PostsEvent {
  final int age;
  final String bloodType;
  final String bloodValue;
  final String city;
  final double addressLat;
  final double addressLon;
  final double hospLat;
  final double hospLon;
  final String userId;
  final BuildContext context;

  CreatePost({
    this.age,
    this.bloodType,
    this.city,
    this.bloodValue,
    this.addressLat,
    this.addressLon,
    this.hospLat,
    this.hospLon,
    this.userId,
    this.context,
  });
}
