import 'package:flutter/material.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/components/app_bar.dart';
import 'package:bloodbank/components/input_container.dart';
import 'package:bloodbank/components/emoji_keyboard.dart';
import 'package:bloodbank/components/say_thanks.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/models/message_data.dart';
import 'package:bloodbank/widgets/message_list.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  static String chatScreen = 'Chat_Screen';
  final String name;
  final String phone;
  String chatId;
  String sender = '';
  String receiver = '';
  final ChatApiClient apiClient;

  ChatScreen({
    this.name,
    this.phone,
    this.chatId,
    this.sender,
    this.receiver,
    this.apiClient,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool thanksFlag = false;
  bool emojiFlag = false;
  bool loading = true;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.chatId == null) {
      getChatId();
    } else {
      getData();
    }
  }

  void getData() async {
    try {
      await widget.apiClient.updateMessageStatus(
        widget.chatId,
        widget.sender,
        widget.receiver,
      );
      Provider.of<ChatData>(this.context, listen: false)
          .getData(widget.sender, widget.receiver, true);
      Provider.of<ChatData>(this.context, listen: false)
          .onMessageReceivedService((result) {
        widget.apiClient.updateMessageStatus(
          widget.chatId,
          widget.sender,
          widget.receiver,
        );
      });
      print('*** <Initial Data Fetch Call> ***');
      setState(() {
        loading = false;
      });
    } catch (e) {
      print('Error: ' + e.toString());
      loading = false;
    }
  }

  void getChatId() async {
    try {
      print(widget.sender);
      print(widget.receiver);
      var result = await widget.apiClient.initiateChat(
        widget.sender,
        widget.receiver,
      );
      print('*** <Chat Initiated> ***');
      setState(() {
        widget.chatId = result['_id'];
        loading = false;
      });
      getData();
    } catch (e) {
      print('Error: ' + e.toString());
      loading = false;
    }
  }

  clearText() {
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    FocusScopeNode focus = FocusScope.of(context);

    return Scaffold(
      appBar: showAppBar(
        context: context,
        backIcon: true,
        title: widget.name,
        subtitle: widget.phone,
        action: '',
        apiClient: widget.apiClient,
        yourId: widget.sender,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              thanksFlag = false;
              emojiFlag = false;
            });
            if (!focus.hasPrimaryFocus) {
              focus.unfocus();
            }
          },
          child: Container(
            color: containerColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: loading
                      ? Center(
                          child: SpinKitFadingCircle(
                            color: secondaryColor,
                            size: 35,
                          ),
                        )
                      : MessagesList(
                          sender: widget.sender,
                          receiver: widget.receiver,
                        ),
                ),
                sayThanks(width, thanksFlag, () {
                  Provider.of<ChatData>(context, listen: false).sendNewMessage(
                    widget.chatId,
                    widget.receiver,
                    'Thank you so much. ☺️',
                  );
                  setState(() {
                    thanksFlag = !thanksFlag;
                  });
                }),
                textInput(width, focus, controller, () {
                  setState(() {
                    thanksFlag = !thanksFlag;
                    emojiFlag = false;
                  });
                }, () {
                  setState(() {
                    thanksFlag = false;
                    emojiFlag = false;
                  });
                }, () {
                  setState(() {
                    emojiFlag ? emojiFlag = false : emojiFlag = true;
                    thanksFlag = false;
                  });
                }, () {
                  if (controller.text != '') {
                    print(widget.chatId);
                    Provider.of<ChatData>(context, listen: false)
                        .sendNewMessage(
                      widget.chatId,
                      widget.receiver,
                      controller.text,
                    );
                    clearText();
                  }
                }),
                emojiBoard(emojiFlag, (emoji) {
                  controller.text += emoji;
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
