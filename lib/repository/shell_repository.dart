import 'dart:async';
import 'dart:convert' as json;

import 'package:dio/dio.dart';
import 'package:example_flutter/model/build_config.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ShellRepository {
  static final ShellRepository _instance = ShellRepository._internal();

  factory ShellRepository() {
    return _instance;
  }

  ShellRepository._internal();

  void connect() {
    _serveInfoController?.close();
    _serveInfoController = PublishSubject<Map<String, dynamic>>();
    _socketChannel = HtmlWebSocketChannel.connect("ws://localhost:8080");
    _socketChannel.stream.listen(
      (message) {
//        _stdOutController.add("onReceived: $message");
        try {
          final serverObj = json.jsonDecode(message);
          if (serverObj != null) {
            if (serverObj["type"] == "stop") {
            } else if (serverObj["code"] != 1) {
              //error
              _stdOutController.add("onReceived: ${serverObj["message"]}");
            } else if (serverObj["code"] == 1) {
              //ok
              if (serverObj["log"] != null) {
                _stdOutController.add("${serverObj["log"]}\n");
              } else {
                _stdOutController.add("onReceived: ${serverObj["message"]}");
              }
            }
          }
        } catch (e) {
          print(e);
        }
      },
      onError: (e) {
        _stdOutController.add("onError: $e");
      },
      onDone: () {
        _stdOutController.add("onDone!");
        _socketChannel = null;
        _serveInfoController?.close();
      },
      cancelOnError: false,
    );
  }

  final _stdOutController = PublishSubject<String>();
  Sink<String> get stdOutSink => _stdOutController.sink;
  Stream<String> get logStream => _stdOutController;

  PublishSubject<Map<String, dynamic>> _serveInfoController;
  Stream<Map<String, dynamic>> get serveInfoStream =>
      _serveInfoController?.stream;

  WebSocketChannel _socketChannel;

  Stream<dynamic> get socketStream => _socketChannel?.stream;

  bool _permissionGranted = false;
  void setPermission(BuildConfig config) async {
    if (_permissionGranted) {
      return;
    }
    _socketChannel.sink.add(json.jsonEncode({
      "type": "exec",
      "cmd": "chmod +x ${config.devEnvironment?.buildFilePath}",
    }));
    _permissionGranted = true;
    _stdOutController
        .add("Granted permission for ${config.devEnvironment?.buildFilePath}");
  }

  Future<Response<dynamic>> build(BuildConfig config) async {
    if (_socketChannel == null) connect();
    await Future.delayed(Duration(seconds: 2));
//    testMessage();
//    return null;

    final args = <String>[];

    //Debug
    args.addAll(["-d", _getBooleanValue(config.debug)]);

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
    args.addAll(["-g", _getBooleanValue(config.needPackagesGet)]);

    //Clear
    args.addAll(["-c", _getBooleanValue(config.needClean)]);

    //Refresh native libraries
    args.addAll(["-l", _getBooleanValue(config.needRefreshNavtiveLibraries)]);

    try {
      setPermission(config);

      _stdOutController.add("command: $args");

      if (config.devEnvironment?.buildFilePath?.isNotEmpty != true) {
        _stdOutController.add("Error: buildFilePath is empty");
      } else {
        final cmd = "${config.devEnvironment?.buildFilePath}" +
            args.map((e) => " $e").join();
        print("cmd=$cmd");
        _socketChannel.sink.add(json.jsonEncode({
          "type": "exec",
          "cmd": cmd,
        }));

        return null;
      }
    } catch (e) {
      _stdOutController.add("Error: ${e.toString()}");
    }
    return null;
  }

  String _getBooleanValue(bool value) => value ? "1" : "0";

  Future<dynamic> stopBuild() async {
    _socketChannel.sink.add(json.jsonEncode({
      "type": "stop",
    }));
    _stdOutController.add("Process Terminated!");
    return null;
  }

  void saveDevEnvironment(DevEnvironment devEnvironment) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString(
        DevEnvironment.BUILD_FILE_PATH, devEnvironment.buildFilePath);
    sharedPrefs.setString(
        DevEnvironment.FLUTTER_ROOT, devEnvironment.flutterRoot);
    sharedPrefs.setString(
        DevEnvironment.ANDROID_HOME, devEnvironment.androidHome);
    sharedPrefs.setString(DevEnvironment.JAVA_HOME, devEnvironment.javaHome);
  }

  Future<DevEnvironment> getDevEnvironment() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final d = DevEnvironment(
      buildFilePath: sharedPrefs.getString(DevEnvironment.BUILD_FILE_PATH),
      flutterRoot: sharedPrefs.getString(DevEnvironment.FLUTTER_ROOT),
      androidHome: sharedPrefs.getString(DevEnvironment.ANDROID_HOME),
      javaHome: sharedPrefs.getString(DevEnvironment.JAVA_HOME),
    );
    return d;
  }
}
