import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';

Widget emojiBoard(bool emojiFlag, Function emojiCallback) {
  return emojiFlag
      ? EmojiPicker(
          rows: 4,
          columns: 7,
          indicatorColor: secondaryColor,
          buttonMode: ButtonMode.MATERIAL,
          noRecentsStyle: TextStyle(color: secondaryColor),
          onEmojiSelected: (emoji, category) {
            emojiCallback(emoji.emoji);
          },
        )
      : Container(
          height: 0,
          width: 0,
        );
}
