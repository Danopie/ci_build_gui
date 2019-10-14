import 'dart:io';

import 'package:example_flutter/model/build_config.dart';
import 'package:rxdart/rxdart.dart';

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

//  String buildFilePath = "/Users/danle/Desktop/untitled.sh";
  String buildFilePath = "/Workspace/dc3/dev/buyer_mobile/clean-build-deloy.sh";

  Future<dynamic> build(BuildConfig config) async {
    final args = <String>[];

    //Path
    args.add(buildFilePath);

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

    //Cleac
    args.addAll(["-c", _getBooleanValue(config.needClean)]);

    //Refresh native libraries
    args.addAll(["-l", _getBooleanValue(config.needRefreshNavtiveLibraries)]);

    try {
      process = await Process.start(
        'sh',
        args,
        includeParentEnvironment: true,
      );

      process.stdout.listen((out) {
        _stdOutController.add(String.fromCharCodes(out));
      });

      process.stderr.listen((err) {
        _stdOutController.add(String.fromCharCodes(err));
      });
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
}
