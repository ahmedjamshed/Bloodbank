String getChat(String sender, String receiver, int pageNo) {
  int maxItem = 15;
  int limit = pageNo * maxItem;
  int skip = (pageNo - 1) * maxItem;
  return """
  query {
  messages(
    sender: "$sender",
    receiver: "$receiver",
    limit: $limit,
    skip: $skip,
  ) {
    data,
    sender,
    createdAt,
  }
}
  """;
}

String getChats(String yourId) {
  return """
  query {
  chats(
    yourId: "$yourId",
  ) {
    _id,
    initiator,
    supporter,
    messages(
      limit: 1,
      sort: _ID_DESC,
    ) {
      _id,
      data,
      status,
      type,
      sender,
      receiver,
      createdAt,
      updatedAt,
    },
  }
}
  """;
}
