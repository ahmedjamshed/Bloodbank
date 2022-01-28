part of 'posts_bloc.dart';

@immutable
class PostsState {
  PostsState({
    this.name = const Name.pure(),
    this.disease = const Disease.pure(),
    this.check = false,
    this.status = FormzStatus.pure,
  });

  final Name name;
  final Disease disease;
  final bool check;
  final FormzStatus status;

  PostsState copyWith({
    Name name,
    Disease disease,
    bool check,
    FormzStatus status,
  }) {
    return PostsState(
      name: name ?? this.name,
      disease: disease ?? this.disease,
      check: check ?? this.check,
      status: status ?? this.status,
    );
  }

  List<Object> get props => [name, disease, check, status];
}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsSuccess extends PostsState {
  final List<Post> posts;
  final bool hasReachedMax;

  PostsSuccess({this.posts, this.hasReachedMax});

  PostsSuccess copyWith({
    Name name,
    Disease disease,
    bool check,
    FormzStatus status,
    List<Post> posts,
    bool hasReachedMax,
  }) {
    return PostsSuccess(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [posts, hasReachedMax];

  @override
  String toString() =>
      'PostSuccess { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}

class PostsFailure extends PostsState {
  final String message;

  PostsFailure({this.message});
}
