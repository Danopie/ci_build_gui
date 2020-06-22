import 'package:primitive_type_parser/primitive_type_parser.dart';

class Types {
  static const exec = "exec";
  static const stopExec = "stopExec";
}

class ClientMessage {
  final String type;
  final String cmd;

  ClientMessage({
    this.type,
    this.cmd,
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
  final ClientMessage clientMessage;
  final String type;
  final int code;
  final int clientCount;
  final bool busy;
  final String message;
  final String log;

  ServerMessage({
    this.type,
    this.log,
    this.clientMessage,
    this.code,
    this.clientCount,
    this.busy,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientMessage': clientMessage == null ? null : clientMessage.toJson(),
      'type': type == null ? null : type,
      'code': code == null ? null : code,
      'clientCount': clientCount == null ? null : clientCount,
      'busy': busy == null ? null : busy,
      'message': message == null ? null : message,
      'log': log == null ? null : log,
    };
  }

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    return ServerMessage(
      clientMessage: json['clientMessage'] == null
          ? null
          : ClientMessage.fromJson(json['clientMessage']),
      type: json['type'] == null ? null : parseString(json['type']),
      code: json['code'] == null ? null : parseInt(json['code']),
      clientCount:
          json['clientCount'] == null ? null : parseInt(json['clientCount']),
      busy: json['busy'] == null ? null : parseBool(json['busy']),
      message: json['message'] == null ? null : parseString(json['message']),
      log: json['log'] == null ? null : parseString(json['log']),
    );
  }
}

class ServerState {
  bool connected;
  dynamic error;

  ServerState({
    this.connected,
    this.error,
  });

  ServerState copyWith({
    bool connected,
    dynamic error,
  }) {
    return new ServerState(
      connected: connected ?? this.connected,
      error: error ?? this.error,
    );
  }
}
