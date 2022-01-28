import 'package:flutter/material.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/models/message_data.dart';
import 'package:provider/provider.dart';

import 'message_bubble.dart';

class MessagesList extends StatefulWidget {
  final String sender;
  final String receiver;

  MessagesList({
    this.sender,
    this.receiver,
  });

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatData>(
      builder: (context, chatData, child) {
        if (chatData.messageCount == 0) {
          return Center(
            child: Text(
              'Send message to start conversation',
              style: TextStyle(color: secondaryColor, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          reverse: true,
          physics: ClampingScrollPhysics(),
          itemCount: chatData.messageCount,
          controller: _scrollController,
          itemBuilder: (context, index) {
            final message = chatData.getMessages()[index];
            return MessageBubble(
              text: message.text,
              date: message.date,
              isMe: message.isMe,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold &&
        !Provider.of<ChatData>(this.context, listen: false).hasMaxReached) {
      Provider.of<ChatData>(this.context, listen: false)
          .getData(widget.sender, widget.receiver, false);
    }
  }
}
