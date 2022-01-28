import 'package:bloodbank/constants/app.dart';

String signup(String fname, String lName, String email, String password,
    String fcmToken) {
  return """
  mutation{
    signUp(email: "$email" , password: "$password", firstName: "$fname", lastName: "$lName", fcmID: "$fcmToken"){ 
         accessToken
    }
}
""";
}

String signin(String email, String password, String fcmToken) {
  return """
  mutation{
    signIn(email: "$email" , password: "$password", fcmID: "$fcmToken"){ 
         accessToken
    }
}
""";
}

String update(String gender, int age, String address, String city, String phone,
    String reason, String picture, String bloodType) {
  print(picture);
  return """
    mutation{
      updateUserProfile(input: 
        {
          gender: $gender, 
          age: $age, 
          address: "$address",
          city: "$city", 
          reason: $reason,
          profilePic: "$picture",

          level:{phone: {number: "$phone"}} 
        }
    )
    {
      _id
      firstName,
      lastName,
      email,
      locale,
      profile{
        gender,
        age,
        address,
        city,
        reason,
        profilePic,
      }
      profileLevel,
      createdAt,
      updatedAt
    }
  }
""";
}

String updatePhone(
  String phone,
) {
  return """
    mutation{
      updateUserProfile(input: 
        {
          level:{phone: {number: "$phone"}} 
        }
    )
    {
      _id
      firstName,
      lastName,
    }
  }
""";
}

String updateCnic(
  String cnic,
) {
  return """
    mutation{
      updateUserProfile(input: 
        {
          level:{cnic: {imageUrl: "$cnic"}} 
        }
    )
    {
      _id
      firstName,
      lastName,
    }
  }
""";
}

String updateMedical(
  String medical,
) {
  return """
    mutation{
      updateUserProfile(input: 
        {
          level:{medicalReport: {medicalReportUrl: "$medical"}} 
        }
    )
    {
      _id
      firstName,
      lastName,
    }
  }
""";
}

String updateReasonType(
  String reason,
) {
  return """
    mutation{
      updateUserProfile(input: 
        {
          reason: $reason
        }
    )
    {
      _id
      firstName,
      lastName,
    }
  }
""";
}

String createPost(
    String name,
    int age,
    String disease,
    String bloodValue,
    String bloodType,
    String city,
    double addressLat,
    double addressLon,
    double hospLat,
    double hospLon,
    String userId) {
  return """
      mutation {
        createPost(record: {
          name: "$name" , 
          age: $age,
          disease: "$disease",
          bloodType: $bloodValue,
          componentType: $bloodType,
          city: "$city",
          address: { 
            type: Point,
            coordinates: [$addressLat, $addressLon]
          },
          hospital: { 
            type: Point,
            coordinates: [$hospLat, $hospLon]
          },
        }) 
        {
          record{
            name
            age
          }
        }
    }
  """;
}

String getToken() {
  return """
      mutation {
        getToken (appId: "$app") {
          accessToken,
        }
      }
  """;
}
