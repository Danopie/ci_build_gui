import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:example_flutter/helper/di/injector.dart';
import 'package:example_flutter/model/build_config.dart';
import 'package:rxdart/rxdart.dart';

import './bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _shellRepository = Injector.shellRepository;

  @override
  HomeState get initialState => HomeIdleState(
        logStrs: List<String>(),
        buildConfig: BuildConfig.defaultConfig(),
        flavors: const <String>["test", "pilot", "production"],
      );

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is InitBlocEvent) {
      final environment = await _shellRepository.getDevEnvironment();
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig:
            currentState.buildConfig.copyWith(devEnvironment: environment),
      );

      _shellRepository.connect();
    } else if (event is UpdateFlavorEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          flavor: event.flavor,
        ),
      );
    } else if (event is BuildEvent) {
      yield HomeBuildingState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig,
      );

      await _shellRepository.build(currentState.buildConfig);

//      yield HomeIdleState(
//        flavors: currentState.flavors,
//        buildConfig: currentState.buildConfig,
//      );
    } else if (event is StopBuildEvent) {
      _shellRepository.stopBuild();

      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig,
      );
    } else if (event is UpdateBranchEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          flutterModule: event.flutterModule,
          androidModule: event.flutterModule,
          iosModule: event.iosModule,
        ),
      );
    } else if (event is UpdateBuildModeEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          mode: event.mode,
        ),
      );
    } else if (event is UpdateNeedCleanEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          needClean: event.value,
        ),
      );
    } else if (event is UpdatePackagesGetEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          needPackagesGet: event.value,
        ),
      );
    } else if (event is UpdateRefreshNativeEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          needRefreshNavtiveLibraries: event.value,
        ),
      );
    } else if (event is UpdateEnvironmentEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig
            .copyWith(devEnvironment: event.devEnvironment),
      );
      _shellRepository.saveDevEnvironment(event.devEnvironment);
    }
  }

  @override
  Stream<HomeState> transformEvents(events, next) {
    return (events as Observable<HomeEvent>).switchMap(next);
  }
}
