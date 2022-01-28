import 'dart:convert';
import 'dart:io';

import 'package:bloodbank/components/app_bar.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/message_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class NotificationsTab extends StatefulWidget {
  final ApiClient apiClient;
  final ChatApiClient chatApi;

  NotificationsTab({this.apiClient, this.chatApi});

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;
  List notifications = [];
  String myId;

  @override
  void initState() {
    super.initState();
    myId = Provider.of<ChatData>(this.context, listen: false).myId;
    loadNotifications();
  }

  void loadNotifications() async {
    prefs = await _prefs;
    final notificationsData = prefs.getString("notifications");
    if (notificationsData != null) {
      final list = json.decode(notificationsData);
      print(list);
      setState(() {
        notifications = list;
      });
    }
  }

  Widget returnEmpty(double height) {
    return Container(
      height: height * 0.75,
      child: Center(
        child: Text(
          'No notification to show!',
          style: TextStyle(
            color: secondaryColor,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: bg_color,
      appBar: showAppBar(
        context: context,
        title: 'Notifications',
        action: '',
        backIcon: false,
      ),
      body: SafeArea(
        child: Container(
          color: pageColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: width * 0.02),
                child: Column(
                  children: <Widget>[
                    notifications.length == 0
                        ? returnEmpty(height)
                        : Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Blood Shoutouts",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    prefs.remove("notifications");
                                    setState(() {
                                      notifications = [];
                                    });
                                  },
                                  child: Text(
                                    "Clear All",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                    notifications.length == 0
                        ? Container(
                            height: 0,
                            width: 0,
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              margin: EdgeInsets.all(0),
                              elevation: 0,
                              color: selectedButtonColor,
                              child: SizedBox(
                                height: height * 0.7,
                                child: ListView.builder(
                                  itemCount: notifications.length,
                                  physics: ClampingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var temp = Platform.isAndroid
                                        ? notifications[index]['data']
                                            ['userName']
                                        : notifications[index]['userName'];
                                    return Container(
                                      height: width * 0.3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 20,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  "$temp created a shoutout",
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  notifications[index]
                                                      ['notification']['title'],
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 15,
                                              bottom: 10,
                                            ),
                                            child: SizedBox(
                                              height: width * 0.06,
                                              width: width * 0.45,
                                              child: FlatButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatScreen(
                                                        name:
                                                            notifications[index]
                                                                    ['data']
                                                                ['userName'],
                                                        phone:
                                                            notifications[index]
                                                                    ['data']
                                                                ['phone'],
                                                        sender: myId,
                                                        receiver:
                                                            notifications[index]
                                                                ['data']['id'],
                                                        apiClient:
                                                            widget.chatApi,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                color: bg_color,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                                child: Text(
                                                  "Respond",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontFamily: "Open Sans",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            thickness: 1,
                                            color: notificationDivider,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
