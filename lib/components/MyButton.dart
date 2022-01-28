import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final double myPadding;
  final double myFontSize;

  MyButton(
      {@required this.title,
      @required this.onClick,
      this.myPadding,
      this.myFontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:myPadding != null ? 0 : 30 , vertical: myPadding != null ? 0 : 30,),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(
          vertical: myPadding != null ? myPadding : 17,
          horizontal: myPadding != null ? 20 : 0,
        ),
        onPressed: onClick,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: primaryColor,
        child: Text(
          title,
          style: TextStyle(
              fontSize: myFontSize != null ? myFontSize : 15,
              color: Colors.white,
              fontFamily: "Open Sans",
              fontWeight:
                  myFontSize != null ? FontWeight.normal : FontWeight.bold),
        ),
      ),
    );
  }
}
