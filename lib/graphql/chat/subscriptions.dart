String newMessage(String yourId) {
  return """
  subscription {
  newMessage(subscriber: "$yourId") {
    _id,
    data,
    type,
    status,
    sender,
    receiver,
    createdAt,
    updatedAt,
    chatId
  }
}
  """;
}

String updateStatusRec(String yourId) {
  return """
  subscription {
  updateStatus(subscriber: "$yourId") {
    chatId
  }
}
  """;
}
