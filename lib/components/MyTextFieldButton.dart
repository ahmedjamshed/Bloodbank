import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

class MyTextFieldButton extends StatelessWidget {
  final String label;
  final Function onClick;
  final String dropdownValue;

  MyTextFieldButton({@required this.label, this.onClick, this.dropdownValue});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 15),
      child: Container(
        height: height * 0.08,
        child: FormField(
          builder: (FormFieldState state) {
            return DropdownButtonHideUnderline(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new InputDecorator(
                    decoration: InputDecoration(
                      labelText: " $label ",
                      labelStyle: TextStyle(
                          color: Color(0xff1F2D50).withOpacity(0.9),
                          fontSize: width * 0.04),
                      contentPadding: EdgeInsets.only(left: 30, right: 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff1F2D50).withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff1F2D50).withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                    ),
                    isEmpty: dropdownValue == null,
                    child: FlatButton(
                      onPressed: onClick,
                      child: Row(
                        children: [
                          Container(
                              width: width * 0.62,
                              child: Text(
                                dropdownValue,
                                maxLines: 1,
                                style: TextStyle(fontSize: 13),
                              )),
                          Icon(
                            Icons.location_on,
                            color: textColor,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
