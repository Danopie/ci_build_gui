import 'package:example_flutter/model/build_config.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeState {
  final BuildConfig buildConfig;
  final List<String> flavors;

  const HomeState({
    this.buildConfig,
    this.flavors,
  });
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
