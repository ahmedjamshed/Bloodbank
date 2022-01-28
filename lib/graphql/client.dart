import 'dart:io';
import 'package:bloodbank/models/blood_conversion.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:bloodbank/graphql/index.dart';

class RequestFailure implements Exception {}

class ApiClient {
  ApiClient({this.graphQLClient});
  GraphQLClient graphQLClient;

  final policies = Policies(
    fetch: FetchPolicy.networkOnly,
  );

  ApiClient create(String token) {
    final httpLink = HttpLink(
        uri: 'http://172.16.0.189:3050/graphql',
        headers: {"authorization": "Bearer $token"});
    final link = Link.from([httpLink]);
    return ApiClient(
      graphQLClient: GraphQLClient(
        cache: InMemoryCache(),
        link: link,
        defaultPolicies: DefaultPolicies(
          watchQuery: policies,
          query: policies,
          mutate: policies,
        ),
      ),
    );
  }

  Future signUp(String name, String lname, String email, String password,
      String fcmToken) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(signup(name, lname, email, password, fcmToken)),
      onError: (error) => print(error),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future signIn(String email, String password, String fcmToken) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(signin(email, password, fcmToken)),
      onError: (error) => print(error),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future updateProfile(String gender, int age, String address, String city,
      String phone, String reason, String picture, String bloodType) async {
    String val = convertBlood(bloodType);
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode:
          gql(update(gender, age, address, city, phone, reason, picture, val)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future updateNumber(String phone) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(updatePhone(phone)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future updateCNIC(String cnic) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(updateCnic(cnic)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future updateMedicalReport(String medical) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(updateMedical(medical)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future updateReason(String reason) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(updateReasonType(reason)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future createNewPost(
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
    String userId,
  ) async {
    String val = convertBlood(bloodValue);
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(createPost(name, age, disease, val, bloodType, city,
          addressLat, addressLon, hospLat, hospLon, userId)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future getUser() async {
    final QueryResult result = await graphQLClient.query(QueryOptions(
      documentNode: gql(user()),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future getPosts(
    String city,
    String bloodType,
    String donationType,
    String userType,
    String profileLevel,
    int skip,
    int limit,
    bool filter,
  ) async {
    final QueryResult result = await graphQLClient.query(QueryOptions(
      documentNode: gql(posts(city, bloodType, donationType, userType,
          int.parse(profileLevel), skip, limit, filter)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future getUsersData(String userId) async {
    final QueryResult result = await graphQLClient.query(QueryOptions(
      documentNode: gql(users(userId)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }
}
