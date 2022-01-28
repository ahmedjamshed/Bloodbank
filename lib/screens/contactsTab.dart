import 'dart:convert';

import 'package:bloodbank/components/app_bar.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/contact.dart';
import 'package:bloodbank/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ContactsTab extends StatefulWidget {
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String myId;
  bool back = false;

  ContactsTab({
    this.apiClient,
    this.chatApi,
    this.myId,
    this.back,
  });

  @override
  _ContactsTabState createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Contact> contacts = [];
  @override
  void initState() {
    super.initState();
    getContactList();
  }

  void getContactList() async {
    final SharedPreferences prefs = await _prefs;
    final contactsData = prefs.getString("contacts");
    if (contactsData != null) {
      final list = json.decode(contactsData);
      if (list.length == 0) {
        contacts = null;
      } else {
        for (final item in list) {
          contacts.add(
            Contact(
              id: item['id'],
              name: item['name'],
              phone: item['phone'],
            ),
          );
        }
      }
    } else {
      contacts = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: bg_color,
      appBar: showAppBar(
        context: context,
        title: 'Contacts',
        action: '',
        backIcon: widget.back,
      ),
      body: SafeArea(
        child: Container(
          color: pageColor,
          child: Column(
            children: <Widget>[
              Expanded(
                child: contacts == null
                    ? Center(
                        child: Text(
                          "No Contacts found!",
                          style: TextStyle(color: secondaryColor, fontSize: 17),
                        ),
                      )
                    : (contacts.length == 0)
                        ? Center(
                            child: SpinKitDoubleBounce(
                              color: primaryColor,
                              size: 20,
                            ),
                          )
                        : ListView.builder(
                            itemCount: contacts == null ? 0 : contacts.length,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04),
                                child: new Column(
                                  children: <Widget>[
                                    FlatButton(
                                      padding: EdgeInsets.symmetric(
                                          vertical: width * 0.03),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              apiClient: widget.chatApi,
                                              sender: widget.myId,
                                              receiver: contacts[index].id,
                                              name: contacts[index].name,
                                              phone: contacts[index].phone,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Image.asset(
                                                'images/contactsIcon.png',
                                                width: 25,
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Text(
                                                  contacts[index].name,
                                                  style: TextStyle(
                                                    color: Color(0xff666666),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      color: Color(0xffB3B3B3).withOpacity(0.8),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
