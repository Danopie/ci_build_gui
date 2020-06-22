import 'dart:async';
import 'dart:convert' as json;
import 'dart:io';

import 'package:example_flutter/helper/string_utils.dart';
import 'package:example_flutter/model/build_config.dart';
import 'package:example_flutter/screen/main/main_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/html.dart';

class SocketRepository {
  static final TAG = "SocketRepository";
  static final SocketRepository _instance =
      SocketRepository._internal("localhost:8080");

  factory SocketRepository() {
    return _instance;
  }

  SocketRepository._internal(this.domain);

  final String domain;
  HtmlWebSocketChannel _socketChannel;

  final serverStateStream = BehaviorSubject<ServerState>();
  final serverMessageStream = BehaviorSubject<ServerMessage>();

  ServerState get serverState => serverStateStream.value;
  void updateServerState(ServerState state) {
    serverStateStream.add(state);
  }

  void connect() {
    if (_socketChannel != null) {
      print("$TAG: Already connected!");
      return;
    }
    _socketChannel = HtmlWebSocketChannel.connect("ws://$domain");
    print("$TAG: Connected!");
    updateServerState(serverState.copyWith(connected: true));
    onServerMessage();
  }

  Future<dynamic> disconnect() async {
    if (_socketChannel == null) {
      print("$TAG: Already disconnected!");
      return null;
    }
    final res = await _socketChannel.sink.close(WebSocketStatus.normalClosure);
    return res;
  }

  void onServerMessage() {
    _socketChannel.stream.listen(
      (message) {
        print("$TAG.onServerMessage: $message");
        try {
          final data = ServerMessage.fromJson(json.jsonDecode(message));
          if (data != null) {
            onServerMessageData(data);
          } else {
            onServerMessageError(StateError("Parse json fail: $message"));
          }
        } catch (e) {
          onServerMessageError(e);
        }
      },
      onError: (e) {
        onServerMessageError(e);
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

  void onServerMessageError(dynamic e) {
    print("$TAG.onServerMessageError: $e");

    updateServerState(serverState.copyWith(error: e));
  }

  void _sendToServer(dynamic data) {
    if (data is String) {
      _socketChannel.sink.add(data);
    } else if (data is Map<String, dynamic>) {
      _socketChannel.sink.add(json.jsonEncode(data));
    } else {
      print("$TAG._sendToServer: what is $data");
    }
  }

  /// actions

  void build(BuildConfig config) {
    final args = <String>[];
    //Debug
    args.addAll(["-d", getBooleanValue(config.debug)]);
    //Branch
    if (config.flutterModule?.isNotEmpty == true) {
      args.addAll(["-n", config.flutterModule]);
    }
    if (config.androidModule?.isNotEmpty == true) {
      args.addAll(["-q", config.androidModule]);
    }
    if (config.iosModule?.isNotEmpty == true) {
      args.addAll(["-w", config.iosModule]);
    }
    //Build Mode
    switch (config.mode) {
      case BuildMode.Normal:
        break;
      case BuildMode.IosOnly:
        args.addAll(["-i", "1"]);
        break;
      case BuildMode.AndroidOnly:
        args.addAll(["-a", "1"]);
        break;
      case BuildMode.EditEnviromentOnly:
        args.addAll(["-e", "1"]);
        break;
      case BuildMode.FlutterBuildOnly:
        args.addAll(["-f", "1"]);
        break;
      case BuildMode.BuildFileOnly:
        args.addAll(["-b", "1"]);
        break;
      case BuildMode.UploadOnly:
        args.addAll(["-u", "1"]);
        break;
    }
    //Packages get
    args.addAll(["-g", getBooleanValue(config.needPackagesGet)]);
    //Clear
    args.addAll(["-c", getBooleanValue(config.needClean)]);
    //Refresh native libraries
    args.addAll(["-l", getBooleanValue(config.needRefreshNavtiveLibraries)]);

    try {
      final cmd = "${config.devEnvironment?.buildFilePath}" +
          args.map((e) => " $e").join();
      print("$TAG.build: command=$cmd");
      _sendToServer(ClientMessage(
        type: Types.exec,
        cmd: cmd,
      ).toJson());
    } catch (e) {
      print("$TAG.build.error: $e");
    }
  }

  void stopBuild() {
    _sendToServer(ClientMessage(
      type: Types.stopExec,
    ));
  }
}
