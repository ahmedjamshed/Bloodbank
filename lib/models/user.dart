import 'package:bloodbank/models/profile.dart';

class User {
  String id;
  String fName;
  String lName;
  String email;
  String locale;
  Profile profile;
  String profileLevel;
  String phone;
  bool phoneVerified;
  String cnic;
  bool cnicVerified;
  String medical;
  bool medicalVerified;

  User({
    this.id,
    this.fName,
    this.lName,
    this.email,
    this.locale,
    this.profile,
    this.profileLevel,
    this.phone,
    this.phoneVerified,
    this.cnic,
    this.cnicVerified,
    this.medical,
    this.medicalVerified,
  });
}
