import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

Widget textInput(
  double width,
  FocusScopeNode focus,
  TextEditingController controller,
  Function thanksCallback,
  Function textInputCallback,
  Function emojiCallback,
  Function msgSendCallback,
) {
  return Padding(
    padding: EdgeInsets.only(
      bottom: width * 0.01,
      top: width * 0.007,
    ),
    child: Container(
      width: width,
      child: Row(
        children: <Widget>[
          Container(
            width: width * 0.125,
            child: IconButton(
              tooltip: 'say thanks',
              onPressed: () {
                thanksCallback();
              },
              icon: Image.asset(
                'assets/icons/plus.png',
              ),
            ),
          ),
          Container(
            width: width * 0.75,
            decoration: BoxDecoration(
              color: selectedButtonColor,
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: width * 0.6,
                  child: TextField(
                    onTap: () {
                      textInputCallback();
                    },
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    // maxLength: 200,
                    maxLengthEnforced: true,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(color: textInputColor),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        top: width * 0.01,
                        bottom: width * 0.01,
                        left: width * 0.06,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabled: true,
                      hintText: 'Text Message',
                      hintStyle: TextStyle(
                        color: containerColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'select emojis',
                  icon: Image.asset(
                    'assets/icons/emoji.png',
                    width: width * 0.06,
                    height: width * 0.06,
                  ),
                  onPressed: () {
                    focus.unfocus();
                    // if (!focus.hasPrimaryFocus) {
                    //   focus.unfocus();
                    // }
                    emojiCallback();
                  },
                ),
              ],
            ),
          ),
          Container(
            width: width * 0.125,
            child: IconButton(
              tooltip: 'send message',
              onPressed: () {
                msgSendCallback();
              },
              icon: Image.asset(
                'assets/icons/sendIcon.png',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
