import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:bloodbank/graphql/chat/client.dart';

Widget showAppBar({
  @required BuildContext context,
  bool backIcon = false,
  @required String title,
  String subtitle = '',
  @required String action,
  ChatApiClient apiClient,
  String yourId,
}) {
  return AppBar(
    backgroundColor: secondaryColor,
    automaticallyImplyLeading: false,
    centerTitle: false,
    leading: backIcon == true
        ? IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: appBarTextColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        : null,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != '')
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          )
      ],
    ),
    actions: [
      if (action == 'menu')
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: appBarTextColor,
          ),
          onPressed: () {
            print('menu pressed');
          },
        ),
      if (action == 'search')
        IconButton(
          icon: Icon(
            Icons.search,
            color: appBarTextColor,
          ),
          onPressed: () {
            print('search pressed');
          },
        ),
    ],
  );
}
