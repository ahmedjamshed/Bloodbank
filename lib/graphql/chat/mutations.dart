String token(String appId) {
  return """
  mutation {
  getToken(appId: "$appId") {
    accessToken,
  }
}
  """;
}

String initChat(String sender, String receiver) {
  return """
  mutation {
  initChat(
    sender: "$sender",
    receiver: "$receiver",
  ) {
    _id,
    initiator,
    supporter,
  }
}
  """;
}

String sendMsg(
  String chatId,
  String sender,
  String receiver,
  String message,
) {
  return """
  mutation {
  sendMessage(
    chatId: "$chatId",
    sender: "$sender",
    receiver: "$receiver",
    messageData: "$message",
    messageType: MESSAGE,
  ) {
    _id,
    data,
    status,
    sender,
    receiver,
    createdAt,
    updatedAt,
  }
}
  """;
}

String updateStatus(String chatId, String yourId, String sender) {
  return """
  mutation {
  updateMessageStatus(
    chatId: "$chatId",
    yourId: "$yourId",
    sender: "$sender",
    status: READ,
  ) {
    succeed,
  }
}
  """;
}
