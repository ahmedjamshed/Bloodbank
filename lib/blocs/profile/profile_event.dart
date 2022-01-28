part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class PhoneChanged extends ProfileEvent {
  const PhoneChanged({@required this.phone});

  final String phone;

  @override
  List<Object> get props => [phone];
}

class AddressChanged extends ProfileEvent {
  const AddressChanged({@required this.address});

  final String address;

  @override
  List<Object> get props => [address];
}

class UpdateProfile extends ProfileEvent {
  final String gender;
  final int age;
  final String city;
  final String reason;
  final String bloodType;
  final BuildContext context;
  final ChatApiClient chatApi;
  final String picture;

  UpdateProfile({
    this.gender,
    this.age,
    this.city,
    this.reason,
    this.bloodType,
    this.context,
    this.chatApi,
    this.picture,
  });
}

class UpdateCnic extends ProfileEvent {
  final String cnic;

  UpdateCnic({this.cnic});
}

class UpdateMedical extends ProfileEvent {
  final String medical;

  UpdateMedical({this.medical});
}

class UpdatePhone extends ProfileEvent {
  final String phone;

  UpdatePhone({this.phone});
}

class UpdateReason extends ProfileEvent {
  final String reason;
  final BuildContext context;

  UpdateReason({this.reason, this.context});
}

class GetUser extends ProfileEvent {
  final BuildContext context;

  GetUser({this.context});
}
