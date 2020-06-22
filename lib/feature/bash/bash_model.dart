import 'package:primitive_type_parser/primitive_type_parser.dart';

class MessageTypes {
  static const exec = "exec";
  static const stopExec = "stopExec";
}

class Bash {
  final String command;

  Bash({
    this.command,
  });

  Map<String, dynamic> toJson() {
    return {
      'command': command == null ? null : command,
    };
  }

  factory Bash.fromJson(Map<String, dynamic> json) {
    return Bash(
      command: json['command'] == null ? null : parseString(json['command']),
    );
  }
}

class ServerBash {
  final bool busy;
  final String latestLog;

  ServerBash({
    this.busy,
    this.latestLog,
  });

  Map<String, dynamic> toJson() {
    return {
      'busy': busy == null ? null : busy,
      'latestLog': latestLog == null ? null : latestLog,
    };
  }

  factory ServerBash.fromJson(Map<String, dynamic> json) {
    return ServerBash(
      busy: json['busy'] == null ? null : parseBool(json['busy']),
      latestLog:
          json['latestLog'] == null ? null : parseString(json['latestLog']),
    );
  }
}
