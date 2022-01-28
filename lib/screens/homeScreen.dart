import 'package:bloodbank/components/MyButton.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/loginScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  static String homeScreen = 'Home_screen';
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final FirebaseMessaging firebaseMessaging;

  HomeScreen({
    this.apiClient,
    this.chatApi,
    this.yourId,
    this.firebaseMessaging,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: sliderColor,
            image: DecorationImage(
              image: AssetImage('images/saveLivesLayer.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  height: height * 0.88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.asset(
                            'images/saveLives.png',
                            height: width * 0.38,
                            width: width * 0.38,
                          ),
                          SizedBox(height: height * 0.02),
                          Center(
                              child: Text(
                            "Save Lives",
                            style: TextStyle(
                                color: textColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          )),
                          SizedBox(height: height * 0.02),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 100,
                            ),
                            child: Center(
                                child: Text(
                              "Save lives and be of great help to many people in need by voluntarily donating blood.",
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              style: TextStyle(color: textColor),
                            )),
                          ),
                        ],
                      ),
                      MyButton(
                        title: "GET STARTED",
                        onClick: () async {
                          final SharedPreferences prefs = await _prefs;
                          prefs.setString("firstLaunch", "okay");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: RouteSettings(
                                name: LoginScreen.loginScreen,
                              ),
                              builder: (context) => LoginScreen(
                                apiClient: apiClient,
                                chatApi: chatApi,
                                yourId: yourId,
                                firebaseMessaging: firebaseMessaging,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
