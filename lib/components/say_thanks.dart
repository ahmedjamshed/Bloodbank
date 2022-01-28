import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

Widget sayThanks(double width, bool thanksFlag, Function thanksCallback) {
  return thanksFlag
      ? FlatButton(
          padding: EdgeInsets.only(left: 10, right: 0),
          onPressed: () {
            thanksCallback();
          },
          child: Container(
            height: width * 0.09,
            width: width * 0.25,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Center(
                child: Text(
              'Say Thanks',
              style: TextStyle(
                color: containerColor,
                fontSize: width * 0.038,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
        )
      : Container(
          height: 0,
          width: 0,
        );
}
