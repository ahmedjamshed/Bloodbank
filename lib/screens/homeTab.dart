import 'package:bloodbank/blocs/posts/posts_bloc.dart';
import 'package:bloodbank/blocs/profile/profile_bloc.dart';
import 'package:bloodbank/components/AvatarWidget.dart';
import 'package:bloodbank/components/dataListPage.dart';
import 'package:bloodbank/components/profileVerificationPage.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/constants/styles.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/blood_conversion.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/screens/shoutOutScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:bloodbank/constants/extensions.dart";
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatelessWidget {
  static String homeTab = 'Home_tab';
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;

  HomeTab({
    this.apiClient,
    this.chatApi,
    this.yourId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(apiClient: apiClient)..add(GetUser(context: context)),
      child: BlocProvider(
        create: (context) => PostsBloc(apiClient: apiClient),
        child: Home(
          apiClient: apiClient,
          chatApi: chatApi,
          yourId: yourId,
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;

  Home({
    this.apiClient,
    this.chatApi,
    this.yourId,
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selected = 0;
  String donationType;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    getDonationType();
  }

  void getDonationType() async {
    final SharedPreferences prefs = await _prefs;
    final resp = prefs.getString('selected');
    if (resp != '' && resp != null) {
      setState(() {
        donationType = resp; // selected not available initially.
      });
    } else {
      setState(() {
        donationType = 'blood';
      });
    }
  }

  void subscribeFCMTopic(User user) async {
    final SharedPreferences prefs = await _prefs;
    final String oldBloodTopic = prefs.getString("blood_topic");
    final String oldPlasmaTopic = prefs.getString("plasma_topic");
    final String oldPlateletsTopic = prefs.getString("platelets_topic");
    // print(oldBloodTopic);
    // print(oldPlasmaTopic);
    // print(oldPlateletsTopic);
    if (oldBloodTopic != null && oldBloodTopic != '') {
      _firebaseMessaging.subscribeToTopic(oldBloodTopic);
    }
    if (oldPlasmaTopic != null && oldPlasmaTopic != '') {
      _firebaseMessaging.subscribeToTopic(oldPlasmaTopic);
    }
    if (oldPlateletsTopic != null && oldPlateletsTopic != '') {
      _firebaseMessaging.subscribeToTopic(oldPlateletsTopic);
    }
  }

  Widget pageWidget(String city, String profileLevel, User user) {
    subscribeFCMTopic(user);
    if (selected == 0) {
      return DataListPage(
        city: city,
        level: profileLevel,
        apiClient: widget.apiClient,
        chatApi: widget.chatApi,
        yourId: widget.yourId,
        user: user,
        donationType: donationType,
      );
    }
    return ProfileVerificationPage(user: user, apiClient: widget.apiClient);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: bg_color,
      floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileSuccess && selected == 0) {
            return FloatingActionButton(
              onPressed: () {
                if (state.user.profile.bloodType == null ||
                    state.user.profileLevel == "0") {
                  showToast("Profile not verified yet.");
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      settings:
                          RouteSettings(name: ShoutOutScreen.shoutOutScreen),
                      builder: (context) => ShoutOutScreen(
                        userID: state.user.id,
                        apiClient: widget.apiClient,
                        userType: state.user.profile.reason,
                      ),
                    ),
                  );
                }
              },
              child: Image.asset('images/shoutOut.png'),
              backgroundColor: Colors.transparent,
            );
          }
          return Container(width: 1, height: 0);
        },
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Container(
                height: height,
                color: pageColor,
                child: Center(
                  child: SpinKitDoubleBounce(
                    color: primaryColor,
                    size: 20,
                  ),
                ),
              );
            } else if (state is ProfileFailure) {
            } else if (state is ProfileSuccess) {
              String val = convertBlood(state.user.profile.bloodType);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 15),
                    child: Row(
                      children: <Widget>[
                        AvatarWidget(
                          parentRadius: 45.0,
                          childRadius: 40.0,
                          image: state.user.profile.picture,
                        ),
                        SizedBox(
                          width: width * 0.06,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: width * 0.5,
                              child: Text(
                                "${state.user.fName} ${state.user.lName}",
                                textAlign: TextAlign.start,
                                style: kProfileDetailTitleStyle,
                              ),
                            ),
                            Container(
                              height: 1,
                              width: width * 0.35,
                              color: divider_color,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              state.user.profileLevel == "0"
                                  ? "Unverified Profile"
                                  : "Verified Profile",
                              textAlign: TextAlign.start,
                              style: kProfileDetailTitleStyle,
                            ),
                            Container(
                              height: 1,
                              width: width * 0.35,
                              color: divider_color,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: <Widget>[
                                for (int i = 0;
                                    i < int.parse(state.user.profileLevel);
                                    i++)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: width * 0.03),
                                    child: Image.asset(
                                      'images/star.png',
                                      height: 25,
                                      width: 25,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'images/blood.png',
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        DataWidget(
                          text: state.user.profile.bloodType == null
                              ? 'Unverified'
                              : val,
                          width: width,
                        ),
                        SizedBox(
                          width: width * 0.07,
                        ),
                        Image.asset(
                          'images/location.png',
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        DataWidget(
                          text: state.user.profile.city,
                          width: width,
                        ),
                        SizedBox(
                          width: width * 0.07,
                        ),
                        Image.asset(
                          'images/donor.png',
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        DataWidget(
                          text: state.user.profile.reason.capitalize(),
                          width: width,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: width * 0.03,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                      ),
                                    ),
                                    color: selected == 0
                                        ? unSelectedButtonColor
                                        : selectedButtonColor,
                                    onPressed: () {
                                      if (selected != 0) {
                                        BlocProvider.of<ProfileBloc>(context)
                                            .add(GetUser(context: context));
                                        setState(() {
                                          selected = 0;
                                        });
                                      }
                                    },
                                    padding: EdgeInsets.symmetric(
                                      vertical: width * 0.025,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Ask For \nBlood",
                                          style: TextStyle(
                                            color: bg_color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: width * 0.04,
                                          ),
                                        ),
                                        Container(
                                          height: selected == 0 ? 1 : 0,
                                          width: width * 0.25,
                                          color: divider_color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    color: selected == 1
                                        ? unSelectedButtonColor
                                        : selectedButtonColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: width * 0.025,
                                    ),
                                    onPressed: () {
                                      if (selected != 1) {
                                        setState(() {
                                          selected = 1;
                                        });
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Profile \nVerifications',
                                          style: TextStyle(
                                            color: bg_color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: width * 0.04,
                                          ),
                                        ),
                                        Container(
                                          height: selected == 1 ? 1 : 0,
                                          width: width * 0.35,
                                          color: divider_color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pageWidget(
                            state.user.profile.city,
                            state.user.profileLevel,
                            state.user,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return Container(height: height, color: pageColor);
          },
        ),
      ),
    );
  }
}

class DataWidget extends StatelessWidget {
  final double width;
  final String text;

  DataWidget({@required this.text, @required this.width});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: <Widget>[
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Container(
            height: 1,
            width: width * 0.05,
            color: divider_color,
          )
        ],
      ),
    );
  }
}
