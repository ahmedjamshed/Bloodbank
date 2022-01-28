import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import '../graphql/chat/client.dart';
import 'message.dart';

class ChatData extends ChangeNotifier {
  List<Message> _messages = [];
  final ChatApiClient apiClient;
  String yourId;
  int pageNo = 1;
  bool _hasMaxReached = false;

  ChatData({this.apiClient, this.yourId});

  UnmodifiableListView<Message> getMessages() {
    return _messages.length == 0 ? null : UnmodifiableListView(_messages);
  }

  void setId(id) {
    print('SET ID is called: ' + id);
    yourId = id;
  }

  void getData(String sender, String receiver, bool forceLoad) async {
    if (forceLoad == true) {
      _hasMaxReached = false;
    }
    if (_hasMaxReached == true) {
      return;
    }
    pageNo = forceLoad ? 1 : pageNo + 1;
    var response = await apiClient.getSpecificChat(sender, receiver, pageNo);
    print('&&& <Data Fetched> &&&');
    if (response is String) {
      print('Error: ' + response);
      pageNo = pageNo == 1 ? 1 : pageNo - 1;
    } else {
      if (forceLoad) {
        _messages.clear();
      }
      if (response['messages'].length < 1) {
        pageNo = pageNo == 1 ? 1 : pageNo - 1;
        _hasMaxReached = true;
      }
      String date;
      for (var data in response['messages']) {
        var temp = DateTime.parse(data['createdAt']).toLocal();
        date = returnDate(temp);
        _messages.add(
          Message(
            id: data['_id'],
            date: date,
            text: data['data'],
            isMe: data['sender'] == yourId,
          ),
        );
      }
      notifyListeners();
    }
  }

  void onMessageReceivedService(Function callback) {
    apiClient.onMessageReceived(yourId, (result) {
      callback(result);
      String date;
      var data = result.data["newMessage"];
      if (_messages.indexWhere((element) => element.id == data['_id']) < 0) {
        print('@@@ <Message Received> @@@');
        var temp = DateTime.parse(data['createdAt']).toLocal();
        date = returnDate(temp);
        _messages.insert(
          0,
          Message(
            id: data['_id'],
            date: date,
            text: data['data'],
            isMe: data['sender'] == yourId,
          ),
        );
        notifyListeners();
      }
    });
  }

  void sendNewMessage(
    String chatId,
    String receiver,
    String message,
  ) async {
    final response = await apiClient.sendMessage(
      chatId,
      yourId,
      receiver,
      message,
    );
    if (response is String) {
      print('Error: ' + response);
    } else {
      print('*** <New Message Sent> ***');
    }
  }

  String returnDate(dynamic date) {
    var currentDate = DateTime.now();
    var temp1 = DateFormat.yMMMd().format(currentDate);
    var temp2 = DateFormat.yMMMd().format(date);
    if (temp1 == temp2) {
      return 'Today, ${DateFormat.jm().format(date)}';
    }
    return '${DateFormat.MMMd().format(date)}, ${DateFormat.jm().format(date)}';
  }

  void onUpdateStatusReceived(Function callback) {
    apiClient.onUpdateStatusReceived(yourId, callback);
  }

  int get messageCount {
    return _messages.length;
  }

  bool get hasMaxReached {
    return _hasMaxReached;
  }

  String get myId {
    return yourId;
  }
}
