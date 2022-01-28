import 'package:bloodbank/components/AvatarWidget.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

class ListCardItem extends StatelessWidget {
  const ListCardItem({
    Key key,
    @required this.width,
    this.name,
    this.bloodType,
    this.address,
    this.city,
    this.addClick,
    this.sendClick,
    this.level,
    this.image,
  }) : super(key: key);

  final double width;
  final String name;
  final String bloodType;
  final String level;
  final String address;
  final String city;
  final Function addClick;
  final Function sendClick;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 3,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10, bottom: 40),
              child: AvatarWidget(
                parentRadius: 33.0,
                childRadius: 30.0,
                image: image,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Open Sans",
                                    fontSize: width * 0.04),
                              ),
                              SizedBox(
                                height: width * 0.003,
                              ),
                              Container(
                                height: 0.5,
                                width: width * 0.35,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: width * 0.015, right: width * 0.05),
                          child: Column(
                            children: <Widget>[
                              Text(
                                bloodType,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Open Sans",
                                    fontSize: 10),
                              ),
                              SizedBox(
                                height: width * 0.003,
                              ),
                              Container(
                                height: 0.5,
                                width: width * 0.1,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: width * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            level == "0"
                                ? "Unverified Profile"
                                : level == "1"
                                    ? "Bronce Profile"
                                    : level == "2"
                                        ? "Gold Profile"
                                        : "Platinum Profile",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Open Sans",
                                fontSize: width * 0.04),
                          ),
                          SizedBox(
                            height: width * 0.003,
                          ),
                          Container(
                            height: 0.5,
                            width: width * 0.35,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: width * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: width * 0.1),
                            child: Text(
                              "$address, $city",
                              maxLines: 2,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Open Sans",
                                  fontSize: width * 0.021),
                            ),
                          ),
                          SizedBox(
                            height: width * 0.003,
                          ),
                          Container(
                            height: 0.5,
                            width: width * 0.45,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: width * 0.025,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                            height: width * 0.06,
                            width: width * 0.3,
                            child: FlatButton(
                              onPressed: sendClick,
                              color: bg_color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Text(
                                "Send message",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: "Open Sans"),
                              ),
                            )),
                        SizedBox(
                            height: width * 0.06,
                            width: width * 0.3,
                            child: FlatButton(
                              onPressed: addClick,
                              color: bg_color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Text(
                                "Add to Contacts",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: "Open Sans",
                                ),
                              ),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: width * 0.04,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
