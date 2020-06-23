import 'package:example_flutter/feature/config_dialog/build_config.dart';
import 'package:example_flutter/feature/home/data/home_model.dart';
import 'package:example_flutter/helper/socket/socket_model.dart';
import 'package:example_flutter/helper/socket/socket_repository.dart';
import 'package:example_flutter/helper/string_utils.dart';

class HomeRepository {
  static const TAG = "HomeRepository";
  final socket = SocketRepository();

  void setup() {
    socket.connect();
  }

  void dispose() {
    socket.disconnect();
  }

  bool requestBuild(BuildConfig config) {
    if (socket?.serverState?.connected != true) return false;

    final cmd = _generateExecCommand(config);
    socket.sendToServer(ClientMessage(
      type: MessageTypes.exec,
      data: {
        'cmd': cmd,
      },
    ).toJson());
    return true;
  }

  String _generateExecCommand(BuildConfig config) {
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
    if (config.needIOS && !config.needAndroid) {
      args.addAll(["-i", "1"]);
    } else if (config.needAndroid && !config.needIOS) {
      args.addAll(["-a", "1"]);
    }

    try {
      final cmd = "${config.devEnvironment?.buildFilePath}" +
          args.map((e) => " $e").join();
      print("$TAG._generateExecCommand: $cmd");
      return cmd;
    } catch (e) {
      print("$TAG._generateExecCommand.error: $e");
    }

    return null;
  }

  bool requestStopBuilding() {
    if (socket?.serverState?.connected != true) return false;

    socket.sendToServer(ClientMessage(
      type: MessageTypes.stop,
    ).toJson());
    return true;
  }
}
