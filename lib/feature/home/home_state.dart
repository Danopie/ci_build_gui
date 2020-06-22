import 'package:example_flutter/feature/config_dialog/build_config.dart';
import 'package:example_flutter/helper/socket/socket_model.dart';

class HomeStateIds {
  static const loading = "loading";
  static const idle = "idle";
  static const busy = "busy";
  static const requesting = "requesting";
}

class HomeState {
  final String state;
  final BuildConfig buildConfig;
  final List<String> flavors;
  final ServerMessage serverMessage;

  HomeState({
    this.state,
    this.buildConfig,
    this.flavors,
    this.serverMessage,
  });

  HomeState copyWith({
    String state,
    BuildConfig buildConfig,
    List<String> flavors,
    ServerMessage serverMessage,
  }) {
    return new HomeState(
      state: state ?? this.state,
      buildConfig: buildConfig ?? this.buildConfig,
      flavors: flavors ?? this.flavors,
      serverMessage: serverMessage ?? this.serverMessage,
    );
  }
}

class HomeBuildingState extends HomeState {
  HomeBuildingState({
    List<String> logStrs,
    BuildConfig buildConfig,
    List<String> flavors,
  }) : super(
          buildConfig: buildConfig,
          flavors: flavors,
        );
}

class HomeIdleState extends HomeState {
  HomeIdleState({
    List<String> logStrs,
    BuildConfig buildConfig,
    List<String> flavors,
  }) : super(
          buildConfig: buildConfig,
          flavors: flavors,
        );
}
