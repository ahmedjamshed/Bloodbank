import 'package:bloodbank/blocs/profile/profile_bloc.dart';
import 'package:bloodbank/components/app_bar.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/constants/styles.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/loginScreen.dart';
import 'package:bloodbank/screens/termsScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contactUs.dart';
import 'helpScreen.dart';

class SettingsTab extends StatelessWidget {
  static String settingsTab = 'Settings_Tab';
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final FirebaseMessaging firebaseMessaging;

  SettingsTab({
    this.apiClient,
    this.chatApi,
    this.firebaseMessaging,
    this.yourId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(apiClient: apiClient)..add(GetUser(context: context)),
      child: Settings(
        apiClient: apiClient,
        chatApi: chatApi,
        firebaseMessaging: firebaseMessaging,
        yourId: yourId,
      ),
    );
  }
}

class Settings extends StatefulWidget {
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final FirebaseMessaging firebaseMessaging;

  Settings({
    this.apiClient,
    this.chatApi,
    this.firebaseMessaging,
    this.yourId,
  });
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool bloodSwitch;
  bool plasmaSwitch;
  bool plateletSwitch;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    validateSelection();
  }

  void validateSelection() async {
    final SharedPreferences prefs = await _prefs;
    final bloodVal = prefs.get("blood_val");
    final plasmaVal = prefs.get("plasma_val");
    final plateletVal = prefs.get("platelets_val");
    setState(() {
      bloodSwitch = (bloodVal != "" && bloodVal != null) ? true : false;
      plasmaSwitch = (plasmaVal != "" && plasmaVal != null) ? true : false;
      plateletSwitch =
          (plateletVal != "" && plateletVal != null) ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: bg_color,
      appBar: showAppBar(
        context: context,
        title: 'Settings',
        action: '',
        backIcon: false,
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
              return Container(
                color: pageColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    MySwitch(
                      switchVal: bloodSwitch,
                      title: 'Opt in for blood donation',
                      subTitle:
                          '(At least medical & phone verification required)',
                      onChange: (val) async {
                        final SharedPreferences prefs = await _prefs;
                        prefs.setString("blood_val", val ? "blood" : "");
                        if (!val) {
                          _firebaseMessaging.unsubscribeFromTopic(
                              '${state.user.profile.reason}_${state.user.profile.bloodType}_blood');
                          prefs.setString("blood_topic", '');
                        } else {
                          final String newTopic =
                              '${state.user.profile.reason}_${state.user.profile.bloodType}_blood';
                          _firebaseMessaging.subscribeToTopic(newTopic);
                          prefs.setString("blood_topic", newTopic);
                          print(newTopic);
                        }
                        setState(() {
                          bloodSwitch = val;
                        });
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    MySwitch(
                      switchVal: plasmaSwitch,
                      title: 'Opt in for plasma donation',
                      subTitle:
                          '(At least medical & phone verification required)',
                      onChange: (val) async {
                        final SharedPreferences prefs = await _prefs;
                        prefs.setString("plasma_val", val ? "plasma" : "");

                        if (!val) {
                          _firebaseMessaging.unsubscribeFromTopic(
                              '${state.user.profile.reason}_${state.user.profile.bloodType}_plasma');
                          prefs.setString("plasma_topic", '');
                        } else {
                          final String newTopic =
                              '${state.user.profile.reason}_${state.user.profile.bloodType}_plasma';
                          _firebaseMessaging.subscribeToTopic(newTopic);
                          prefs.setString("plasma_topic", newTopic);
                          print(newTopic);
                        }
                        setState(() {
                          plasmaSwitch = val;
                        });
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    MySwitch(
                      switchVal: plateletSwitch,
                      title: 'Opt in for platelets donation',
                      subTitle:
                          '(At least medical & phone verification required)',
                      onChange: (val) async {
                        final SharedPreferences prefs = await _prefs;
                        prefs.setString(
                            "platelets_val", val ? "platelets" : "");

                        if (!val) {
                          _firebaseMessaging.unsubscribeFromTopic(
                              '${state.user.profile.reason}_${state.user.profile.bloodType}_platelets');
                          prefs.setString("platelets_topic", '');
                        } else {
                          final String newTopic =
                              '${state.user.profile.reason}_${state.user.profile.bloodType}_platelets';
                          _firebaseMessaging.subscribeToTopic(newTopic);
                          prefs.setString("platelets_topic", newTopic);
                          print(newTopic);
                        }
                        setState(() {
                          plateletSwitch = val;
                        });
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    MySwitch(
                      switchVal:
                          state.user.profile.reason == "donor" ? true : false,
                      title: 'I am a donor',
                      subTitle: '',
                      onChange: (val) async {
                        BlocProvider.of<ProfileBloc>(context).add(
                          UpdateReason(
                            reason: val ? "donor" : "receiver",
                            context: context,
                          ),
                        );
                        final SharedPreferences prefs = await _prefs;
                        final String oldBloodTopic =
                            prefs.getString("blood_topic");
                        final String oldPlasmaTopic =
                            prefs.getString("plasma_topic");
                        final String oldPlateletsTopic =
                            prefs.getString("platelets_topic");
                        if (oldBloodTopic != null && oldBloodTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldBloodTopic);
                        }
                        if (oldPlasmaTopic != null && oldPlasmaTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldPlasmaTopic);
                        }
                        if (oldPlateletsTopic != null &&
                            oldPlateletsTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldPlateletsTopic);
                        }

                        String bloodTopic = '';
                        String plasmaTopic = '';
                        String plateletsTopic = '';

                        if (bloodSwitch) {
                          bloodTopic =
                              '${val ? "donor" : "receiver"}_${state.user.profile.bloodType}_blood';
                          _firebaseMessaging.subscribeToTopic(bloodTopic);
                        }

                        if (plasmaSwitch) {
                          plasmaTopic =
                              '${val ? "donor" : "receiver"}_${state.user.profile.bloodType}_plasma';
                          _firebaseMessaging.subscribeToTopic(plasmaTopic);
                        }

                        if (plateletSwitch) {
                          plateletsTopic =
                              '${val ? "donor" : "receiver"}_${state.user.profile.bloodType}_platelets';
                          _firebaseMessaging.subscribeToTopic(plateletsTopic);
                        }

                        prefs.setString("blood_topic", bloodTopic);
                        prefs.setString("plasma_topic", plasmaTopic);
                        prefs.setString("platelets_topic", plateletsTopic);
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    MySwitch(
                      switchVal:
                          state.user.profile.reason == "donor" ? false : true,
                      title: 'I am receiver',
                      subTitle: '',
                      onChange: (val) async {
                        BlocProvider.of<ProfileBloc>(context).add(
                          UpdateReason(
                            reason: val ? "receiver" : "donor",
                            context: context,
                          ),
                        );
                        final SharedPreferences prefs = await _prefs;
                        final String oldBloodTopic =
                            prefs.getString("blood_topic");
                        final String oldPlasmaTopic =
                            prefs.getString("plasma_topic");
                        final String oldPlateletsTopic =
                            prefs.getString("platelets_topic");
                        if (oldBloodTopic != null && oldBloodTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldBloodTopic);
                        }
                        if (oldPlasmaTopic != null && oldPlasmaTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldPlasmaTopic);
                        }
                        if (oldPlateletsTopic != null &&
                            oldPlateletsTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldPlateletsTopic);
                        }

                        String bloodTopic = '';
                        String plasmaTopic = '';
                        String plateletsTopic = '';

                        if (bloodSwitch) {
                          bloodTopic =
                              '${val ? "receiver" : "donor"}_${state.user.profile.bloodType}_blood';
                          _firebaseMessaging.subscribeToTopic(bloodTopic);
                        }

                        if (plasmaSwitch) {
                          plasmaTopic =
                              '${val ? "receiver" : "donor"}_${state.user.profile.bloodType}_plasma';
                          _firebaseMessaging.subscribeToTopic(plasmaTopic);
                        }

                        if (plateletSwitch) {
                          plateletsTopic =
                              '${val ? "receiver" : "donor"}_${state.user.profile.bloodType}_platelets';
                          _firebaseMessaging.subscribeToTopic(plateletsTopic);
                        }

                        prefs.setString("blood_topic", bloodTopic);
                        prefs.setString("plasma_topic", plasmaTopic);
                        prefs.setString("platelets_topic", plateletsTopic);
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    SettingsButton(
                      width: width,
                      title: "Terms and Policies",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsScreen(),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    SettingsButton(
                      width: width,
                      title: "Help",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelpScreen(),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    SettingsButton(
                      width: width,
                      title: "Contact Us",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactUsScreen(),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                    SettingsButton(
                      width: width,
                      title: "Logout",
                      onClick: () async {
                        final SharedPreferences prefs = await _prefs;
                        final String oldBloodTopic =
                            prefs.getString("blood_topic");
                        final String oldPlasmaTopic =
                            prefs.getString("plasma_topic");
                        final String oldPlateletsTopic =
                            prefs.getString("platelets_topic");
                        if (oldBloodTopic != null && oldBloodTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldBloodTopic);
                        }
                        if (oldPlasmaTopic != null && oldPlasmaTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldPlasmaTopic);
                        }
                        if (oldPlateletsTopic != null &&
                            oldPlateletsTopic != '') {
                          _firebaseMessaging
                              .unsubscribeFromTopic(oldPlateletsTopic);
                        }
                        prefs.setString("auth", null);
                        prefs.setString("blood_val", null);
                        prefs.setString("plasma_val", null);
                        prefs.setString("platelets_val", null);
                        prefs.setString("blood_topic", null);
                        prefs.setString("plasma_topic", null);
                        prefs.setString("platelets_topic", null);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            settings:
                                RouteSettings(name: LoginScreen.loginScreen),
                            builder: (context) => LoginScreen(
                              apiClient: ApiClient().create(""),
                              chatApi: widget.chatApi,
                              yourId: widget.yourId,
                              firebaseMessaging: widget.firebaseMessaging,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 0.5,
                      color: Color(0xff808080),
                    ),
                  ],
                ),
              );
            }
            return Container(height: height, color: pageColor);
          },
        ),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    Key key,
    @required this.width,
    @required this.title,
    @required this.onClick,
  }) : super(key: key);

  final double width;
  final String title;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.only(top: width * 0.04, bottom: width * 0.04),
      onPressed: onClick,
      child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.08),
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: kSettingsTitleStyle,
            ),
          )),
    );
  }
}

class MySwitch extends StatelessWidget {
  final bool switchVal;
  final Function onChange;
  final String title;
  final String subTitle;

  MySwitch({
    @required this.switchVal,
    @required this.onChange,
    @required this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: width * 0.02, horizontal: width * 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: kSettingsTitleStyle,
              ),
              Text(
                subTitle,
                style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Switch(
            onChanged: onChange,
            value: switchVal,
            inactiveTrackColor: Color(0xff606060),
            activeColor: Colors.white,
            activeTrackColor: Color(0xff1F2D50),
          )
        ],
      ),
    );
  }
}
