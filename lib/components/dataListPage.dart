import 'dart:convert';

import 'package:bloodbank/blocs/posts/posts_bloc.dart';
import 'package:bloodbank/components/ListCardItem.dart';
import 'package:bloodbank/constants/bloodTypes.dart';
import 'package:bloodbank/constants/cities.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/constants/profiles.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/contact.dart';
import 'package:bloodbank/models/message_data.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataListPage extends StatelessWidget {
  final String city;
  final String level;
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final User user;
  final String donationType;

  DataListPage({
    this.city,
    this.level,
    this.apiClient,
    this.chatApi,
    this.yourId,
    this.user,
    this.donationType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostsBloc(apiClient: apiClient)
        ..add(
          FetchMatchedPosts(
            city: city,
            bloodType: user.profile.bloodType,
            donationType: donationType,
            userType: user.profile.reason == 'donor' ? 'receiver' : 'donor',
            profileLevel: level,
            filter: true,
            refresh: true,
            context: context,
            chatApi: chatApi,
            yourId: yourId,
          ),
        ),
      child: DataList(
        city: city,
        level: level,
        apiClient: apiClient,
        chatApi: chatApi,
        user: user,
        yourId: yourId,
        donationType: donationType,
      ),
    );
  }
}

class DataList extends StatefulWidget {
  final String city;
  final String level;
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final User user;
  final String donationType;

  DataList({
    this.city,
    this.level,
    this.apiClient,
    this.chatApi,
    this.yourId,
    this.user,
    this.donationType,
  });

  @override
  _DataListState createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostsBloc _postBloc;
  String cityValue;
  String profileValue;
  String userType;
  String donationType;
  bool filter = false;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    cityValue = widget.user.profile.city;
    userType = widget.user.profile.reason;
    donationType = widget.donationType;
    profileValue = profilesList[int.parse(widget.level)];
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostsBloc>(context);
    getContactList();
  }

  void getContactList() async {
    final SharedPreferences prefs = await _prefs;
    final contactsData = prefs.getString("contacts");
    if (contactsData != null) {
      final list = json.decode(contactsData);
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(
        FetchMatchedPosts(
          city: cityValue,
          bloodType: widget.user.profile.bloodType,
          donationType: donationType,
          userType:
              widget.user.profile.reason == 'donor' ? 'receiver' : 'donor',
          profileLevel: profilesList.indexOf(profileValue).toString(),
          filter: filter,
          refresh: false,
          context: context,
          chatApi: widget.chatApi,
          yourId: widget.yourId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var myId = Provider.of<ChatData>(this.context, listen: false).myId;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
            left: width * 0.08, right: width * 0.08, top: width * 0.03),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "City",
                  style: TextStyle(
                    color: bg_color,
                    fontSize: 18,
                    fontFamily: "Open Sans",
                  ),
                ),
                Text(
                  'Donation Type',
                  style: TextStyle(
                    color: bg_color,
                    fontSize: 18,
                    fontFamily: "Open Sans",
                  ),
                )
              ],
            ),
            SizedBox(
              height: width * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ButtonWidget(
                  width: width * 0.5,
                  listValue: cityValue,
                  myList: citiesList,
                  onClick: (val) {
                    if (val != cityValue) {
                      setState(() {
                        cityValue = val;
                        filter = true;
                      });
                      if (val == "All") {
                        _postBloc.add(
                          FetchMatchedPosts(
                            city: cityValue,
                            bloodType: widget.user.profile.bloodType,
                            donationType: donationType,
                            userType: widget.user.profile.reason == 'donor'
                                ? 'receiver'
                                : 'donor',
                            filter: filter,
                            refresh: true,
                            context: context,
                            profileLevel:
                                profilesList.indexOf(profileValue).toString(),
                            chatApi: widget.chatApi,
                            yourId: widget.yourId,
                          ),
                        );
                      } else {
                        _postBloc.add(
                          FetchMatchedPosts(
                            city: cityValue,
                            bloodType: widget.user.profile.bloodType,
                            donationType: donationType,
                            userType: widget.user.profile.reason == 'donor'
                                ? 'receiver'
                                : 'donor',
                            filter: filter,
                            refresh: true,
                            context: context,
                            profileLevel:
                                profilesList.indexOf(profileValue).toString(),
                            chatApi: widget.chatApi,
                            yourId: widget.yourId,
                          ),
                        );
                      }
                    }
                  },
                ),
                ButtonWidget(
                  width: width * 0.3,
                  listValue: donationType,
                  myList: bloodTypes,
                  onClick: (val) {
                    if (val != donationType) {
                      setState(() {
                        donationType = val;
                        filter = true;
                      });
                      _postBloc.add(
                        FetchMatchedPosts(
                          city: cityValue,
                          bloodType: widget.user.profile.bloodType,
                          donationType: donationType,
                          userType: widget.user.profile.reason == 'donor'
                              ? 'receiver'
                              : 'donor',
                          filter: filter,
                          refresh: true,
                          context: context,
                          profileLevel:
                              profilesList.indexOf(profileValue).toString(),
                          chatApi: widget.chatApi,
                          yourId: widget.yourId,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            BlocBuilder<PostsBloc, PostsState>(
              builder: (context, state) {
                if (state is PostsLoading) {
                  return Expanded(
                    child: Container(
                      child: Center(
                        child: SpinKitDoubleBounce(
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                } else if (state is PostsFailure) {
                } else if (state is PostsSuccess) {
                  if (widget.user.profile.bloodType == null) {
                    return Expanded(
                      child: Container(
                        child: Center(
                          child: Text(
                            "Blood unverified to match posts!",
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (state.posts.length == 0) {
                    return Expanded(
                      child: Container(
                        child: Center(
                          child: Text(
                            "No posts found!",
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.hasReachedMax
                          ? state.posts.length
                          : state.posts.length + 1,
                      controller: _scrollController,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        // print(state.posts[0].userId);
                        // user ID who posted
                        return index < state.posts.length
                            ? ListCardItem(
                                addClick: () async {
                                  final SharedPreferences prefs = await _prefs;
                                  bool match = false;
                                  for (final contact in contacts) {
                                    if (contact.id ==
                                        state.posts[index].userId) {
                                      match = true;
                                      break;
                                    }
                                  }
                                  if (match) {
                                    showToast(
                                        "Contact already added in your contacts!");
                                  } else {
                                    contacts.add(
                                      Contact(
                                          id: state.posts[index].userId,
                                          name:
                                              "${state.posts[index].user.fName} ${state.posts[index].user.lName}",
                                          phone: state.posts[index].user.phone),
                                    );
                                    final jsonData = json.encode(contacts);
                                    print(jsonData);
                                    prefs.setString("contacts", jsonData);
                                    showToast("Contact added Successfully!");
                                  }
                                },
                                sendClick: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        apiClient: widget.chatApi,
                                        sender: myId,
                                        receiver: state.posts[index].userId,
                                        name:
                                            "${state.posts[index].user.fName} ${state.posts[index].user.lName}",
                                        phone: state.posts[index].user.phone,
                                      ),
                                    ),
                                  );
                                },
                                image: state.posts[index].user.profile.picture,
                                width: width,
                                name:
                                    "${state.posts[index].user.fName} ${state.posts[index].user.lName}",
                                bloodType: state.posts[index].bloodType,
                                address:
                                    state.posts[index].user.profile.address,
                                city: state.posts[index].city,
                                level: state.posts[index].user.profileLevel,
                              )
                            : state.posts.length == 1
                                ? null
                                : BottomLoader();
                      },
                    ),
                  );
                }
                return Container(
                  height: 0,
                  width: 1,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: SpinKitDoubleBounce(
            color: primaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key key,
    @required this.width,
    @required this.listValue,
    @required this.onClick,
    this.myList,
  }) : super(key: key);

  final double width;
  final String listValue;
  final Function onClick;
  final List<String> myList;

  @override
  Widget build(BuildContext context) {
    final myWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: myWidth * 0.02),
      child: Container(
        width: width,
        height: myWidth * 0.09,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              iconEnabledColor: Colors.white,
              value: listValue,
              isDense: true,
              onChanged: onClick,
              dropdownColor: secondaryColor,
              items: myList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: SizedBox(
                    width: width * 0.7,
                    child: Text(
                      value,
                      maxLines: 02,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
