import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget returnLoading(bool loading, double height) {
  if (loading == true) {
    return Container(
      height: height * 0.777,
      child: Center(
        child: SpinKitFadingCircle(
          color: secondaryColor,
          size: 35,
        ),
      ),
    );
  } else
    return Container(
      height: 0,
      width: 0,
    );
}
