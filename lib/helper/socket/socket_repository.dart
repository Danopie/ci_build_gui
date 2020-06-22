import 'dart:async';
import 'dart:convert' as json;
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/html.dart';

import 'socket_model.dart';

class SocketRepository {
  static final TAG = "SocketRepository";

  static final SocketRepository _instance =
      SocketRepository._internal("localhost:8080");

  factory SocketRepository() {
    return _instance;
  }

  SocketRepository._internal(this.domain) {
    serverStateStream.add(ServerState(connected: false, clientCount: 0));
  }

  final String domain;
  HtmlWebSocketChannel _socketChannel;
  final serverStateStream = BehaviorSubject<ServerState>();
  final serverMessageStream = BehaviorSubject<ServerMessage>();

  ServerState get serverState => serverStateStream.value;

  void updateServerState(ServerState info) {
    serverStateStream.add(info);
  }

  void connect() {
    if (_socketChannel != null) {
      print("$TAG: Already connected!");
      return;
    }
    _socketChannel = HtmlWebSocketChannel.connect("ws://$domain");
    if (_socketChannel != null) {
      print("$TAG: Connected!");
      updateServerState(serverState.copyWith(connected: true));
      onServerMessage();
    } else {
      print("$TAG: connect fail!");
      updateServerState(
          serverState.copyWith(connected: false, error: "connect fail"));
    }
  }

  Future<dynamic> disconnect() async {
    if (_socketChannel == null) {
      print("$TAG: Already disconnected!");
      return null;
    }
    final res = await _socketChannel.sink.close(WebSocketStatus.normalClosure);
    return res;
  }

  ServerMessage parseServerMessage(String message) {
    return ServerMessage.fromJson(json.jsonDecode(message));
  }

  void onServerMessage() {
    _socketChannel.stream.listen(
      (message) {
        print("$TAG.onServerMessage: $message");
        try {
          final data = parseServerMessage(message);
          if (data != null) {
            updateServerState(serverState.copyWith(
              clientCount: data.state?.clientCount,
              error: data.state?.error,
            ));
            onServerMessageData(data);
          } else {
            onServerMessageError("Parse json fail: $message");
          }
        } catch (e) {
          onServerMessageError(e?.toString());
        }
      },
      onError: (e) {
        onServerMessageError(e?.toString());
      },
      onDone: () {
        print("$TAG: Disconnected!");
        updateServerState(serverState.copyWith(connected: false));
        _socketChannel = null;
      },
      cancelOnError: false,
    );
  }

  void onServerMessageData(ServerMessage data) {
    print("$TAG.onServerMessageData");
    serverMessageStream.add(data);
  }

  void onServerMessageError(String e) {
    print("$TAG.onServerMessageError: $e");

    updateServerState(serverState.copyWith(error: e));
  }

  void sendToServer(dynamic data) {
    if (_socketChannel == null) {
      print("$TAG._sendToServer: not connected to Server");
      return;
    }
    if (data is String) {
      _socketChannel?.sink?.add(data);
    } else if (data is Map<String, dynamic>) {
      _socketChannel?.sink?.add(json.jsonEncode(data));
    } else {
      print("$TAG._sendToServer: what is $data");
    }
  }
}
