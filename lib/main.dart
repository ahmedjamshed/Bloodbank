import 'dart:convert';

import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/contactUs.dart';
import 'package:bloodbank/screens/createAccountScreen.dart';
import 'package:bloodbank/screens/helpScreen.dart';
import 'package:bloodbank/screens/homeScreen.dart';
import 'package:bloodbank/screens/introSlider.dart';
import 'package:bloodbank/screens/loginScreen.dart';
import 'package:bloodbank/screens/mapScreen.dart';
import 'package:bloodbank/screens/chat_screen.dart';
import 'package:bloodbank/screens/moreDetailScreen.dart';
import 'package:bloodbank/screens/searchScreen.dart';
import 'package:bloodbank/screens/shoutOutScreen.dart';
import 'package:bloodbank/screens/tabNavigator.dart';
import 'package:bloodbank/screens/termsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app.dart';
import 'models/message_data.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

/// IMPORTANT: running the following code on its own won't work as there is setup required for each platform head project.
/// Please download the complete example app from the GitHub repository where all the setup has been done
Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ApiClient apiClient;
  String yourId = '';
  String chatToken = '';
  String isFirst;
  final String uri = '172.16.0.189:3051';
  String token;
  ChatApiClient chatApi = ChatApiClient().create("", "172.16.0.189:3051");
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    getMessage();
    createClient(uri);
    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {});
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  void _showNotification(final message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['title'], message['body'], platformChannelSpecifics,
        payload: 'item x');
  }

  void getMessage() async {
    final SharedPreferences prefs = await _prefs;
    final String oldBloodTopic = prefs.getString("blood_topic");
    final String oldPlasmaTopic = prefs.getString("plasma_topic");
    final String oldPlateletsTopic = prefs.getString("platelets_topic");
    if (oldBloodTopic != null && oldBloodTopic != '') {
      _firebaseMessaging.subscribeToTopic(oldBloodTopic);
    }
    if (oldPlasmaTopic != null && oldPlasmaTopic != '') {
      _firebaseMessaging.subscribeToTopic(oldPlasmaTopic);
    }
    if (oldPlateletsTopic != null && oldPlateletsTopic != '') {
      _firebaseMessaging.subscribeToTopic(oldPlateletsTopic);
    }
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        message.forEach((key, value) {
          if (key == "notification") {
            _showNotification(value);
          }
        });
        saveNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        saveNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        saveNotification(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      final SharedPreferences prefs = await _prefs;
      prefs.setString("fcmToken", token);
      print("FCM token:");
      print(token);
    });
  }

  void saveNotification(Map<String, dynamic> message) async {
    final SharedPreferences prefs = await _prefs;
    final String notifications = prefs.getString("notifications");
    if (notifications != null) {
      final list = json.decode(notifications);
      list.add(message);
      String listString = json.encode(list);
      prefs.setString('notifications', listString);
    } else {
      final list = [];
      list.add(message);
      String listString = json.encode(list);
      prefs.setString('notifications', listString);
    }
  }

  void createClient(String uri) async {
    final SharedPreferences prefs = await _prefs;
    var temp = await chatApi.getToken(app);
    final String tempToken = prefs.getString("auth");
    final String userId = prefs.getString("userId");
    final flag = prefs.getString("firstLaunch");
    print('AUTH TOKEN: ');
    print(tempToken);
    print('CHAT TOKEN: ');
    print(temp['getToken']['accessToken']);
    setState(() {
      chatToken = temp['getToken']['accessToken'];
      chatApi = ChatApiClient().create(chatToken, uri);
      token = tempToken;
      yourId = userId;
      apiClient = ApiClient().create(tempToken == null ? "" : tempToken);
      isFirst = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatData(
        apiClient: chatApi,
        yourId: yourId,
      ),
      child: StyledToast(
        locale: const Locale('en', 'US'),
        textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
        backgroundColor: Color(0x75000000),
        borderRadius: BorderRadius.circular(5.0),
        textPadding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
        toastPositions: StyledToastPosition.top,
        toastAnimation: StyledToastAnimation.slideFromBottomFade,
        reverseAnimation: StyledToastAnimation.fade,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastLinearToSlowEaseIn,
        duration: Duration(seconds: 4),
        animDuration: Duration(seconds: 1),
        dismissOtherOnShow: true,
        movingOnWindowChange: true,
        fullWidth: false,
        child: MaterialApp(
          theme: ThemeData(fontFamily: "Open Sans"),
          initialRoute: IntroSliderScreen.introSliderScreen,
          routes: {
            IntroSliderScreen.introSliderScreen: (context) => IntroSliderScreen(
                  token: token,
                  apiClient: apiClient,
                  chatApi: chatApi,
                  yourId: yourId,
                  firebaseMessaging: _firebaseMessaging,
                  isFirst: isFirst,
                ),
            HomeScreen.homeScreen: (context) => HomeScreen(),
            LoginScreen.loginScreen: (context) => LoginScreen(
                  apiClient: apiClient,
                  chatApi: chatApi,
                  yourId: yourId,
                  firebaseMessaging: _firebaseMessaging,
                ),
            CreateAccountScreen.createAccountScreen: (context) =>
                CreateAccountScreen(
                  apiClient: apiClient,
                ),
            MoreDetailScreen.moreDetailScreen: (context) => MoreDetailScreen(
                  apiClient: apiClient,
                ),
            TabNavigator.tabNavigator: (context) => TabNavigator(
                  apiClient: apiClient,
                  chatApi: chatApi,
                  yourId: yourId,
                ),
            ShoutOutScreen.shoutOutScreen: (context) => ShoutOutScreen(),
            ChatScreen.chatScreen: (context) => ChatScreen(),
            MapsScreen.mapScreen: (context) => MapsScreen(),
            SearchScreen.searchScreen: (context) => SearchScreen(),
            TermsScreen.termsScreen: (context) => TermsScreen(),
            HelpScreen.helpScreen: (context) => HelpScreen(),
            ContactUsScreen.contactUsScreen: (context) => ContactUsScreen(),
          },
        ),
      ),
    );
  }
}
