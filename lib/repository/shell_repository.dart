import 'dart:async';

import 'package:dio/dio.dart';
import 'package:example_flutter/model/build_config.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShellRepository {
  static final ShellRepository _instance = ShellRepository._internal();

  factory ShellRepository() {
    return _instance;
  }

  ShellRepository._internal();

  final _stdOutController = PublishSubject<String>();
  Sink<String> get stdOutSink => _stdOutController.sink;

  Stream<String> get logStream => _stdOutController;

  final dio = Dio(BaseOptions(
    baseUrl: "http://localhost:8080/",
    receiveTimeout: 70 * 60000,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "*",
    },
  ));

  Future<Response<String>> build(BuildConfig config) async {
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
      _stdOutController.add("command: $args");

      if (config.devEnvironment?.buildFilePath?.isNotEmpty != true) {
        _stdOutController.add("Error: buildFilePath is empty");
      } else {
//        final setPermission = await dio.get(
//          "exec",
//          queryParameters: {
//            "cmd": "chmod +x ${config.devEnvironment?.buildFilePath}",
//          },
//        );
//        _stdOutController.add("setPermission: ${setPermission.data}");

        final cmd = "${config.devEnvironment?.buildFilePath}" +
            args.map((e) => " $e").join();
        print("cmd=$cmd");
        final result = await dio.get<String>(
          "exec",
          queryParameters: {
            "cmd": cmd,
          },
        );
        _stdOutController.add("${result.data}");
        return result;
      }
    } catch (e) {
      _stdOutController.add("Error: ${e.toString()}");
    }
    return null;
  }

  String _getBooleanValue(bool value) => value ? "1" : "0";

  Future<dynamic> stopBuild() async {
    final result = dio.get<String>(
      "stop",
    );
    _stdOutController.add("Process Terminated!");
    return result;
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
