import 'dart:async';

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
