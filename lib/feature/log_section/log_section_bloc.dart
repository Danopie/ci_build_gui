import 'package:lightweight_bloc/lightweight_bloc.dart';

import 'log_section_state.dart';

class LogSectionBloc extends Bloc<LogSectionState> {
  @override
  void init() {}

  @override
  LogSectionState get initialState => LogSectionState();

  void addLog(String log) {
    update(state.copyWith(logs: List.from(state.logs ?? [])..add(log)));
  }
}
