import 'package:bloodbank/components/app_bar.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  static String helpScreen = 'Help_Screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar(
        context: context,
        title: 'Help',
        action: '',
        backIcon: true,
      ),
      backgroundColor: containerColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: RichText(
              text: TextSpan(
                text: "Help Screen",
                style: TextStyle(color: textColor),
                children: <TextSpan>[
                  TextSpan(
                    text: "\n\nOther Data\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "\nHere\n",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
