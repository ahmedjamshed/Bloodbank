import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String label;
  final String defaultVal;
  final Function onChange;
  final bool obsecure;
  final TextInputType textInputType;
  final Icon icon;
  final Function editingComplete;
  final int limit;

  MyTextField({
    @required this.label,
    this.onChange,
    this.defaultVal,
    this.obsecure,
    this.textInputType,
    this.icon,
    this.editingComplete,
    @required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 15),
      child: Container(
        height: height * 0.09,
        child: TextFormField(
          maxLength: limit,
          keyboardType: textInputType,
          obscureText: obsecure,
          onChanged: onChange,
          onEditingComplete: editingComplete,
          style: TextStyle(
            color: Color(0xff1F2D50).withOpacity(0.9),
          ),
          textAlign: TextAlign.start,
          autocorrect: false,
          cursorColor: Color(0xff1F2D50).withOpacity(0.5),
          decoration: InputDecoration(
            focusColor: primaryColor,
            hintText: label == "Phone" ? "03xx xxxxxxx" : "",
            labelText: " $label ",
            suffixIcon: icon,
            labelStyle: TextStyle(
              color: Color(0xff1F2D50).withOpacity(0.9),
              fontSize: width * 0.04,
            ),
            contentPadding: EdgeInsets.only(left: 30, top: 18, right: 30),
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
        ),
      ),
    );
  }
}
