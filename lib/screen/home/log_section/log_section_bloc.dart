import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:example_flutter/helper/di/injector.dart';
import 'package:example_flutter/screen/home/bloc.dart';
import 'package:example_flutter/screen/home/home_bloc.dart';

import './bloc.dart';

class LogSectionBloc extends Bloc<LogSectionEvent, LogSectionState> {
  final _shellRepository = Injector.shellRepository;

  LogSectionBloc(HomeBloc bloc) {
    bloc.state.listen((state) {
      if (state is HomeBuildingState) {
        dispatch(ClearLogEvent());
      }
    });

    _shellRepository.logStream.listen((str) {
      dispatch(UpdateLogEvent(str));
    });
  }

  @override
  LogSectionState get initialState => LogSectionState(logs: <String>[]);

  @override
  Stream<LogSectionState> mapEventToState(
    LogSectionEvent event,
  ) async* {
    if (event is UpdateLogEvent) {
      final newLogs = currentState.logs;
      newLogs.add(event.log);
      yield LogSectionState(logs: newLogs);
    } else if (event is ClearLogEvent) {
      yield LogSectionState(logs: <String>[]);
    }
  }
}
