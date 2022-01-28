import 'dart:io';

import 'package:bloodbank/graphql/chat/subscriptions.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:bloodbank/graphql/chat/index.dart';

class RequestFailure implements Exception {}

class ChatApiClient {
  ChatApiClient({this.graphQLClient});
  GraphQLClient graphQLClient;

  final policies = Policies(
    fetch: FetchPolicy.networkOnly,
  );

  ChatApiClient create(String token, String uri) {
    Link link = HttpLink(
      uri: 'http://$uri/graphql',
      headers: {"authorization": "Bearer $token"},
    );

    final WebSocketLink websocketLink = WebSocketLink(
      url: 'ws://$uri/subscriptions',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 300),
      ),
    );

    link = link.concat(websocketLink);
    return ChatApiClient(
      graphQLClient: GraphQLClient(
        cache: InMemoryCache(),
        link: link,
        defaultPolicies: DefaultPolicies(
          watchQuery: policies,
          query: policies,
          mutate: policies,
        ),
      ),
    );
  }

  /* */

  /* ---------- Subscriptions ---------- */

  /* */

  void onMessageReceived(String yourId, Function callback) {
    graphQLClient
        .subscribe(
          Operation(
            documentNode: gql(
              newMessage(yourId),
            ),
          ),
        )
        .listen(callback);
  }

  void onUpdateStatusReceived(String yourId, Function callback) {
    graphQLClient
        .subscribe(
          Operation(
            documentNode: gql(
              updateStatusRec(yourId),
            ),
          ),
        )
        .listen(callback);
  }

  /* */

  /* ---------- Mutations ---------- */

  /* */

  Future getToken(String appId) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(token(appId)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future initiateChat(String sender, String receiver) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(initChat(sender, receiver)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data['initChat'];
  }

  Future sendMessage(
    String chatId,
    String sender,
    String receiver,
    String messageText,
  ) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(sendMsg(
        chatId,
        sender,
        receiver,
        messageText,
      )),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  Future updateMessageStatus(
    String chatId,
    String yourId,
    String sender,
  ) async {
    final QueryResult result = await graphQLClient.mutate(MutationOptions(
      documentNode: gql(updateStatus(chatId, yourId, sender)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }

  /* */

  /* ---------- Queries ---------- */

  /* */

  Future getAllChats(
    String yourId,
  ) async {
    final QueryResult result = await graphQLClient.query(QueryOptions(
      documentNode: gql(getChats("$yourId")),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data['chats'];
  }

  Future getSpecificChat(String sender, String receiver, int pageNo) async {
    final QueryResult result = await graphQLClient.query(QueryOptions(
      documentNode: gql(getChat(sender, receiver, pageNo)),
    ));
    if (result.data == null &&
        result.exception.graphqlErrors.length > 0 &&
        result.exception.graphqlErrors[0].message is String) {
      return result.exception.graphqlErrors[0].message;
    }
    return result.data;
  }
}
