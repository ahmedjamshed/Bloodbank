part of 'profile_bloc.dart';

@immutable
class ProfileState {
  ProfileState({
    this.phone = const Phone.pure(),
    this.address = const Address.pure(),
    this.status = FormzStatus.pure,
  });

  final Phone phone;
  final Address address;
  final FormzStatus status;

  ProfileState copyWith({
    Phone phone,
    Address address,
    FormzStatus status,
  }) {
    return ProfileState(
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }

  List<Object> get props => [phone, address];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final User user;
  ProfileSuccess({this.user});
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure({this.message});
}
