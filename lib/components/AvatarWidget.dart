import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final double parentRadius;
  final double childRadius;
  final String image;

  AvatarWidget(
      {@required this.parentRadius,
      @required this.childRadius,
      @required this.image});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: parentRadius,
      backgroundColor: divider_color,
      child: CircleAvatar(
        radius: childRadius,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(image),
      ),
    );
  }
}
