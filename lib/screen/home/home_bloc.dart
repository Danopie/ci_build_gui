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
    if (event is UpdateFlavorEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          flavor: event.flavor,
        ),
      );
    } else if (event is BuildEvent) {
      await _shellRepository.build(currentState.buildConfig);

      yield HomeBuildingState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig,
      );

//      yield HomeIdleState(
//        logStrs: _shellRepository.logData,
//        flavors: currentState.flavors,
//        buildConfig: currentState.buildConfig,
//      );
    } else if (event is StopBuildEvent) {
      await _shellRepository.stopBuild();
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig,
      );
    } else if (event is UpdateBranchEvent) {
      yield HomeIdleState(
        flavors: currentState.flavors,
        buildConfig: currentState.buildConfig.copyWith(
          branch: event.branchName,
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
    }
  }

  @override
  Stream<HomeState> transformEvents(events, next) {
    return (events as Observable<HomeEvent>).switchMap(next);
  }
}
