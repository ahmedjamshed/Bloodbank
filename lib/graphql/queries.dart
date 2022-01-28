String user() {
  return """
  {
  user{
    _id,
    email,
    firstName,
    lastName,
    locale,
    profile{
      profilePic,
      bloodType,
      gender,
      age,
      address,
      city,
      reason,
      level{
        phone{
          number
          verified
        }
        cnic{
          imageUrl
          verified
        }
        medicalReport{
          medicalReportUrl
          verified
        }
      }
    }
    profileLevel,
  }
}
""";
}

String users(String userId) {
  return """
  query {
    users (
      filter: {
        _id: "$userId",
      }
    )
  {
    _id
    firstName
    lastName
    profile {
      level {
        phone {
          number
        }
      }
    }
  }
}
  """;
}

String posts(
  String city,
  String bloodType,
  String donationType,
  String userType,
  int profileLevel,
  int skip,
  int limit,
  bool filter,
) {
  return filter != true
      ? """
  {
    matchedPosts(
      limit: $limit,
      skip: $skip,
      filter: {
        bloodComponent: $donationType,
        userType: $userType,
        bloodType: $bloodType,
      }
    )
      {
        userID
        name
        bloodType
        disease
        city
        user {
          firstName
          lastName
          profileLevel
          email
          profile {
            profilePic
            address
            level {
              phone {
                number
                verified
              }
            }
          }
        }
      }
  }
  """
      : city == "All"
          ? """
  {
    matchedPosts(
      limit: $limit,
      skip: $skip, 
      filter: {
        bloodComponent: $donationType,
        userType: $userType,
        bloodType: $bloodType,
      }
    )
      {
        userID
        name
        bloodType
        disease
        city
        user {
          firstName
          lastName
          profileLevel
          email
          profile {
            profilePic
            address
            level {
              phone {
                number
                verified
              }
            }
          }
        }
      }
  }
  """
          : """
  {
    matchedPosts(
      limit: $limit,
      skip: $skip,
      filter: {
        city: "$city",
        bloodComponent: $donationType,
        userType: $userType,
        bloodType: $bloodType,
      }
    )
      {
        userID
        name
        bloodType
        disease
        city
        user {
          firstName
          lastName
          profileLevel
          email
          profile {
            profilePic
            address
            level {
              phone {
                number
                verified
              }
            }
          }
        }
      }
  }
  """;
}
