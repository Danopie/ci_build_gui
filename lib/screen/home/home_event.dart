import 'package:example_flutter/model/build_config.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeEvent {}

class InitBlocEvent extends HomeEvent {}

class BuildEvent extends HomeEvent {}

class StopBuildEvent extends HomeEvent {}

class UpdateFlavorEvent extends HomeEvent {
  final String flavor;

  UpdateFlavorEvent({
    this.flavor,
  });
}

class UpdateBranchEvent extends HomeEvent {
  final String branchName;

  UpdateBranchEvent({
    this.branchName,
  });
}

class UpdateEnvironmentEvent extends HomeEvent {
  final DevEnvironment devEnvironment;

  UpdateEnvironmentEvent({
    this.devEnvironment,
  });
}

class UpdateBuildModeEvent extends HomeEvent {
  final BuildMode mode;

  UpdateBuildModeEvent({
    this.mode,
  });
}

class UpdateNeedCleanEvent extends HomeEvent {
  final bool value;

  UpdateNeedCleanEvent({
    this.value,
  });
}

class UpdatePackagesGetEvent extends HomeEvent {
  final bool value;

  UpdatePackagesGetEvent({
    this.value,
  });
}

class UpdateRefreshNativeEvent extends HomeEvent {
  final bool value;

  UpdateRefreshNativeEvent({
    this.value,
  });
}
