import 'package:bloodbank/models/user.dart';

class Post {
  String userId;
  String name;
  String bloodType;
  String disease;
  String city;
  User user;

  Post({
    this.userId,
    this.name,
    this.bloodType,
    this.disease,
    this.city,
    this.user,
  });
}
