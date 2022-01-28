import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDropDownTextField extends StatelessWidget {
  final String label;
  final Function onChange;
  final String dropdownValue;
  final List<String> dropDownItems;

  MyDropDownTextField(
      {@required this.label,
      this.dropDownItems,
      this.onChange,
      this.dropdownValue});

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
                      contentPadding:
                          EdgeInsets.only(left: 30, top: 18, right: 30),
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
                    child: new DropdownButton<String>(
                      value: dropdownValue,
                      isDense: true,
                      onChanged: onChange,
                      items: dropDownItems.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
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
