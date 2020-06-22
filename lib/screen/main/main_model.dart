import 'package:flutter/foundation.dart';
import 'package:primitive_type_parser/primitive_type_parser.dart';

class ClientMessage {
  String type;
  String cmd;

  ClientMessage({
    @required this.type,
    @required this.cmd,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type == null ? null : type,
      'cmd': cmd == null ? null : cmd,
    };
  }

  factory ClientMessage.fromJson(Map<String, dynamic> json) {
    return ClientMessage(
      type: json['type'] == null ? null : parseString(json['type']),
      cmd: json['cmd'] == null ? null : parseString(json['cmd']),
    );
  }
}

class ServerMessage {
  ClientMessage clientMessage;
  int code;
  int clientCount;
  bool busy;
  String message;

  ServerMessage({
    @required this.clientMessage,
    @required this.code,
    @required this.clientCount,
    @required this.busy,
    @required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientMessage': clientMessage == null ? null : clientMessage.toJson(),
      'code': code == null ? null : code,
      'clientCount': clientCount == null ? null : clientCount,
      'busy': busy == null ? null : busy,
      'message': message == null ? null : message,
    };
  }

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    return ServerMessage(
      clientMessage: json['clientMessage'] == null
          ? null
          : ClientMessage.fromJson(json['clientMessage']),
      code: json['code'] == null ? null : parseInt(json['code']),
      clientCount:
          json['clientCount'] == null ? null : parseInt(json['clientCount']),
      busy: json['busy'] == null ? null : parseBool(json['busy']),
      message: json['message'] == null ? null : parseString(json['message']),
    );
  }
}
