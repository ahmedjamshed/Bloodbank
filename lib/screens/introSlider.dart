import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/constants/styles.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/homeScreen.dart';
import 'package:bloodbank/screens/loginScreen.dart';
import 'package:bloodbank/screens/tabNavigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class IntroSliderScreen extends StatefulWidget {
  static String introSliderScreen = 'Intro_slider';
  final String token;
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final String isFirst;
  final FirebaseMessaging firebaseMessaging;

  IntroSliderScreen({
    this.token,
    this.apiClient,
    this.firebaseMessaging,
    this.chatApi,
    this.yourId,
    this.isFirst,
  });

  @override
  _IntroSliderScreenState createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Donate Blood",
        description:
            "Donate blood today to fulfill your social responsibility and play your part in saving lives in Pakistan.",
        pathImage: "images/donateBlood.png",
        centerWidget: Text(
          'Donate Blood',
          style: kTitleStyle,
        ),
        backgroundColor: Colors.white,
        styleTitle: kTitleStyle,
        styleDescription: kSubTitleStyle,
        backgroundOpacity: 1,
        backgroundImage: 'images/donateBloodLayer.png',
        backgroundOpacityColor: Colors.white,
      ),
    );
    slides.add(
      new Slide(
        title: "Receive Blood",
        description:
            "In dire need of blood? Simply sign up now to reach out to thousands of blood donors in an instance.",
        pathImage: "images/receiveBlood.png",
        centerWidget: Text(
          'Receive Blood',
          style: kTitleStyle,
        ),
        backgroundColor: Colors.white,
        styleTitle: kTitleStyle,
        styleDescription: kSubTitleStyle,
        backgroundOpacity: 1,
        backgroundImage: 'images/receiveBloodLayer.png',
        backgroundOpacityColor: Colors.white,
      ),
    );
    slides.add(
      new Slide(
        title: "Track Donors",
        description:
            "Receive shout-outs whenever someone creates a post of the blood donation that matches your requirements.",
        pathImage: "images/trackDonors.png",
        centerWidget: Text(
          'Track Donors',
          style: kTitleStyle,
        ),
        backgroundColor: Colors.white,
        styleTitle: kTitleStyle,
        styleDescription: kSubTitleStyle,
        backgroundOpacityColor: Colors.white,
        backgroundOpacity: 1,
        backgroundImage: 'images/trackDonorLayer.png',
      ),
    );
  }

  Widget renderNextBtn() {
    return Text(
      "NEXT",
      style: TextStyle(color: Colors.white),
    );
  }

  Widget renderDoneBtn() {
    return Text(
      "DONE",
      style: TextStyle(color: Colors.white),
    );
  }

  Widget renderPrevBtn() {
    return Text("PREV", style: TextStyle(color: Colors.white));
  }

  List<Widget> renderListCustomTabs(double width, double height) {
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        decoration: BoxDecoration(
          color: sliderColor,
          image: DecorationImage(
            image: AssetImage(currentSlide.backgroundImage),
            fit: BoxFit.fill,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 60.0, top: 60.0),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                  child: Image.asset(
                currentSlide.pathImage,
                width: width * 0.38,
                height: width * 0.38,
                fit: BoxFit.contain,
              )),
              Container(
                child: Text(
                  currentSlide.title,
                  style: currentSlide.styleTitle,
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.only(top: 10.0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Container(
                  child: Text(
                    currentSlide.description,
                    style: currentSlide.styleDescription,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                  ),
                  margin: EdgeInsets.only(top: 5.0),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

  void onDonePress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: HomeScreen.homeScreen),
        builder: (context) => HomeScreen(
          apiClient: widget.apiClient,
          chatApi: widget.chatApi,
          yourId: widget.yourId,
          firebaseMessaging: widget.firebaseMessaging,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return widget.token != null
        ? TabNavigator(
            apiClient: widget.apiClient,
            chatApi: widget.chatApi,
            yourId: widget.yourId,
          )
        : widget.isFirst == null
            ? IntroSlider(
                slides: slides,
                onDonePress: this.onDonePress,
                colorActiveDot: Colors.white,
                colorDot: Colors.white.withOpacity(0.4),
                isShowPrevBtn: true,
                isShowSkipBtn: false,
                listCustomTabs: this.renderListCustomTabs(width, height),
                renderPrevBtn: this.renderPrevBtn(),
                renderNextBtn: this.renderNextBtn(),
                renderDoneBtn: this.renderDoneBtn(),
              )
            : LoginScreen(
                apiClient: widget.apiClient,
                chatApi: widget.chatApi,
                yourId: widget.yourId,
                firebaseMessaging: widget.firebaseMessaging,
              );
  }
}
