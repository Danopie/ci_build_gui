import 'package:primitive_type_parser/primitive_type_parser.dart';

class ClientMessage {
  final String type;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() {
    return {
      'type': type == null ? null : type,
      'data': data,
    };
  }

  factory ClientMessage.fromJson(Map<String, dynamic> json) {
    return ClientMessage(
      type: json['type'] == null ? null : parseString(json['type']),
      data: json['data'],
    );
  }

  const ClientMessage({
    this.type,
    this.data,
  });
}

class ServerState {
  final int clientCount;
  final bool connected;
  final String error;

  ServerState({
    this.connected,
    this.error,
    this.clientCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientCount': clientCount == null ? null : clientCount,
      'connected': connected == null ? null : connected,
      'error': error == null ? null : error,
    };
  }

  factory ServerState.fromJson(Map<String, dynamic> json) {
    return ServerState(
      clientCount:
          json['clientCount'] == null ? null : parseInt(json['clientCount']),
      connected:
          json['connected'] == null ? null : parseBool(json['connected']),
      error: json['error'] == null ? null : parseString(json['error']),
    );
  }

  ServerState copyWith({
    int clientCount,
    bool connected,
    String error,
  }) {
    return new ServerState(
      clientCount: clientCount ?? this.clientCount,
      connected: connected ?? this.connected,
      error: error ?? this.error,
    );
  }
}

class ServerCodes {
  static const error = 0;
  static const ok = 1;
}

class ServerMessage {
  final ServerState state;
  //
  final ClientMessage from;
  //
  final int code;
  final String message;
  //
  final Map<String, dynamic> data;

  const ServerMessage({
    this.from,
    this.code,
    this.message,
    this.state,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state == null ? null : state.toJson(),
      'from': from == null ? null : from.toJson(),
      'code': code == null ? null : code,
      'message': message == null ? null : message,
      'data': data,
    };
  }

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    return ServerMessage(
      state: json['state'] == null ? null : ServerState.fromJson(json['state']),
      from: json['from'] == null ? null : ClientMessage.fromJson(json['from']),
      code: json['code'] == null ? null : parseInt(json['code']),
      message: json['message'] == null ? null : parseString(json['message']),
      data: json['data'],
    );
  }
}
