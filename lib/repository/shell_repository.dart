import 'dart:io';

import 'package:example_flutter/model/build_config.dart';
import 'package:process_run/shell.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShellRepository {
  static final ShellRepository _instance = ShellRepository._internal();

  factory ShellRepository() {
    return _instance;
  }

  ShellRepository._internal() {}

  final _stdOutController = PublishSubject<String>();
  Sink<String> get stdOutSink => _stdOutController.sink;

  Stream<String> get logStream => _stdOutController;

  Process process;

  Future<ProcessResult> build(BuildConfig config) async {
    final args = <String>[];

    //Path
    args.add(config.buildFilePath);

    //Flavor
    args.addAll(["-r", config.flavor]);

    //Debug
    args.addAll(["-d", _getBooleanValue(config.debug)]);

    //Branch
    if (config.branch.isNotEmpty) {
      args.addAll(["-n", config.branch]);
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
      final f = File("/abc.dart");
      print('ShellRepository.build: $f');
      f.writeAsStringSync("abc");

      final environment = Map<String, String>.from(userEnvironment);

      environment.putIfAbsent('FLUTTER_ROOT', () => '/Tools/flutter');

      String path = environment['PATH'];
      path += ":/Tools/flutter/bin";
      path += ":/Tools/flutter/bin/cache/dart-sdk/bin";

      environment['PATH'] = path;

      _stdOutController.add('User Environment');
      environment.forEach((k, v) {
        _stdOutController.add('$k : $v');
      });

      process = await Process.start('sh', args,
          includeParentEnvironment: true,
          runInShell: true,
          environment: environment);

      process.stdout.listen((out) {
        _stdOutController.add(String.fromCharCodes(out));
      });

      process.stderr.listen((err) {
        _stdOutController.add(String.fromCharCodes(err));
      });

      final exitCode = await process.exitCode;
      return ProcessResult(
          process.pid, exitCode, process.stdout, process.stderr);
    } catch (e) {
      _stdOutController.add("Error: ${e.toString()}");
    }
  }

  String _getBooleanValue(bool value) => value ? "1" : "0";

  Future<dynamic> stopBuild() async {
    process.kill();
    _stdOutController.add("Process terminated");
//    final results = await shell.run('''
//      ps -ax | grep "${buildFilePath}" | grep -v "grep" | awk '{print \$1}'
//      ''');
//
//    print('ShellRepository.stopBuild: $results');
//    String processId = results.first.stdout.toString();
//
//    print('ShellRepository.stopBuild: $processId');
//
//    await shell.run('''
//      kill $processId
//      ''');
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
