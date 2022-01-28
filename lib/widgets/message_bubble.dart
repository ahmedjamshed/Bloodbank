import 'package:flutter/material.dart';
import 'package:bloodbank/constants/colors.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.date, this.isMe});

  final String text;
  final String date;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: isMe
                ? EdgeInsets.only(left: width * 0.1)
                : EdgeInsets.only(right: width * 0.1),
            child: Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
              elevation: 5.0,
              color: isMe ? secondaryColor : selectedButtonColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : textInputColor,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: isMe
                ? EdgeInsets.only(
                    right: 5,
                    top: 10,
                  )
                : EdgeInsets.only(
                    left: 5,
                    top: 10,
                  ),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 12.0,
                color: descriptionTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
