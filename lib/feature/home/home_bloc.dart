import 'dart:async';

import 'package:example_flutter/feature/config_dialog/build_config.dart';
import 'package:example_flutter/feature/home/data/home_repository.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart';

import 'home_state.dart';

class HomeBloc extends Bloc<HomeState> {
  final HomeRepository _repository = HomeRepository();
  @override
  void init() async {
    _repository.setup();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  HomeState get initialState => HomeState(
        buildConfig: BuildConfig.defaultConfig(),
      );

  Future<void> requestBuild() async {
    _repository.requestBuild(state.buildConfig);
    update(state.copyWith(state: HomeStateIds.requesting));
  }

  void onUserInputFlutterModuleBranch(String str) {
    update(state.copyWith(
        buildConfig: state.buildConfig.copyWith(flutterModule: str)));
  }

  void onUserInputAndroidModuleBranch(String str) {
    update(state.copyWith(
        buildConfig: state.buildConfig.copyWith(androidModule: str)));
  }

  void onUserInputIOSModuleBranch(String str) {
    update(state.copyWith(
        buildConfig: state.buildConfig.copyWith(iosModule: str)));
  }

  void onUserChangedBuildMode(BuildMode newValue) {
    update(state.copyWith(
        buildConfig: state.buildConfig.copyWith(mode: newValue)));
  }

  void onUserChangedPubGet(bool value) {
    update(state.copyWith(
        buildConfig: state.buildConfig.copyWith(needPackagesGet: value)));
  }

  void onUserChangedRefreshNative(bool value) {
    update(state.copyWith(
        buildConfig:
            state.buildConfig.copyWith(needRefreshNavtiveLibraries: value)));
  }
}
