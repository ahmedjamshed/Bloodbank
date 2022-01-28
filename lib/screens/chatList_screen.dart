import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/contactsTab.dart';
import 'package:flutter/material.dart';
import 'package:bloodbank/components/app_bar.dart';
import 'package:bloodbank/components/chatList_tile_data.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/models/message_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  ChatListScreen({
    this.apiClient,
    this.chatApi,
    this.yourId,
  });
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List contacts = [], users = [];
  bool loading = true, check = true;
  String myId;

  @override
  void initState() {
    super.initState();
    myId = Provider.of<ChatData>(this.context, listen: false).myId;
    getData();
    Provider.of<ChatData>(this.context, listen: false)
        .onMessageReceivedService((result) {
      getData();
    });
  }

  Future getData() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await widget.chatApi.getAllChats(myId);
      print(response);
      if (response is String || response.length == 0) {
        print('Error: ' + response.toString());
        setState(() {
          loading = false;
        });
      } else {
        response.sort((a, b) {
          int stamp1;
          int stamp2;
          if (a['messages'].length > 0) {
            stamp1 = DateTime.parse(a['messages'][0]['createdAt'])
                .millisecondsSinceEpoch;
          } else {
            stamp1 = 11111111;
          }
          if (b['messages'].length > 0) {
            stamp2 = DateTime.parse(b['messages'][0]['createdAt'])
                .millisecondsSinceEpoch;
          } else {
            stamp2 = 00000000;
          }
          return stamp2.compareTo(stamp1);
        });
        setState(() {
          contacts = response;
        });
        await returnUsers();
      }
    } catch (e) {
      print('Error: ' + e.toString());
      showToast('Something went wrong.');
      setState(() {
        loading = false;
      });
    }
  }

  Future returnUsers() async {
    try {
      int index = 0;
      users = [];
      contacts.forEach((element) async {
        if (element['messages'].length != 0) {
          final temp = element['initiator'] == myId
              ? element['supporter']
              : element['initiator'];
          final response = await widget.apiClient.getUsersData(temp);
          if (response is String) {
            print('Internal Error: ' + response.toString());
            setState(() {
              loading = false;
            });
          } else {
            print('USER DATA: ');
            print(response);
            users.add(response);
          }
          if (check) {
            setState(() {
              check = false;
            });
          }
        }
        if (index == contacts.length - 1) {
          contacts.forEach((element) {
            final id = element['initiator'] == myId
                ? element['supporter']
                : element['initiator'];
            users.forEach((data) {
              if (id == data['users'][0]['_id']) {
                element['name'] = data['users'][0]['firstName'] +
                    " " +
                    data['users'][0]['lastName'];
                element['phone'] =
                    data['users'][0]['profile']['level']['phone']['number'];
              }
            });
          });
          setState(() {
            loading = false;
          });
        }
        index++;
      });
    } catch (e) {
      print('Error: ' + e.toString());
      showToast('Something went wrong.');
      setState(() {
        loading = false;
      });
    }
  }

  String returnDate(dynamic date) {
    final currentDate = DateTime.now();
    final temp1 = DateFormat.yMMMd().format(currentDate);
    var temp2 = DateFormat.yMMMd().format(date);
    if (temp1 == temp2) {
      return DateFormat.jm().format(date);
    }
    return temp2;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: showAppBar(
        context: context,
        title: 'Messages',
        action: '',
        backIcon: false,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 28,
          color: Colors.white,
        ),
        backgroundColor: secondaryColor,
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactsTab(
                back: true,
              ),
            ),
          ),
        },
      ),
      body: SafeArea(
        child: Container(
          color: containerColor,
          child: Column(
            children: <Widget>[
              Expanded(
                child: loading
                    ? Center(
                        child: SpinKitFadingCircle(
                          color: secondaryColor,
                          size: 35,
                        ),
                      )
                    : (contacts.length == 0 || check == true)
                        ? Center(
                            child: Text(
                              'No conversation to show!',
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 17,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: ClampingScrollPhysics(),
                            itemCount: contacts.length,
                            itemBuilder: (BuildContext cntxt, int index) {
                              if (contacts[index]['messages'].length == 0) {
                                return Container(
                                  height: 0,
                                  width: 0,
                                );
                              }
                              var date = DateTime.parse(contacts[index]
                                      ['messages'][0]['createdAt'])
                                  .toLocal();
                              String dateTime = returnDate(date);
                              return Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: width * 0.01,
                                        child: Icon(
                                          Icons.fiber_manual_record,
                                          color: '${contacts[index]['messages'][0]['sender']}' ==
                                                  myId
                                              ? Colors.transparent
                                              : '${contacts[index]['messages'][0]['status']}' ==
                                                      'read'
                                                  ? Colors.transparent
                                                  : secondaryColor,
                                          size: 8,
                                        ),
                                      ),
                                      tileData(
                                        id: '${contacts[index]['_id']}',
                                        apiClient: widget.chatApi,
                                        width: width,
                                        context: context,
                                        name: contacts[index]['name'],
                                        phone: contacts[index]['phone'],
                                        date: '$dateTime',
                                        lastMessage:
                                            '${contacts[index]['messages'][0]['data']}',
                                        sender: myId,
                                        receiver: '${contacts[index]['messages'][0]['sender']}' ==
                                                myId
                                            ? '${contacts[index]['messages'][0]['receiver']}'
                                            : '${contacts[index]['messages'][0]['sender']}',
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 1,
                                    color: dividerColor.withOpacity(0.8),
                                  ),
                                ],
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
