import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/screens/chat_screen.dart';

Widget tileData({
  String id,
  ChatApiClient apiClient,
  double width,
  BuildContext context,
  String name,
  String phone,
  String date,
  String lastMessage,
  String sender,
  String receiver,
}) {
  return SizedBox(
    width: width * 0.99,
    child: Column(
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.symmetric(
            vertical: width * 0.04,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  name: name,
                  phone: phone,
                  chatId: id,
                  sender: sender,
                  receiver: receiver,
                  apiClient: apiClient,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: nameTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      date,
                      style: TextStyle(
                        color: descriptionTextColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: width,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02,
                  ),
                  child: Text(
                    lastMessage,
                    maxLines: 1,
                    style: TextStyle(
                      color: descriptionTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
