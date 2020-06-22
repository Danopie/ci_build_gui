import 'package:example_flutter/feature/bash/bash_model.dart';
import 'package:example_flutter/feature/config_dialog/build_config.dart';

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
  final ServerBash serverBash;

  HomeState({
    this.state,
    this.buildConfig,
    this.flavors,
    this.serverBash,
  });

  HomeState copyWith({
    String state,
    BuildConfig buildConfig,
    List<String> flavors,
    ServerBash serverBash,
  }) {
    return new HomeState(
      state: state ?? this.state,
      buildConfig: buildConfig ?? this.buildConfig,
      flavors: flavors ?? this.flavors,
      serverBash: serverBash ?? this.serverBash,
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
