import 'package:lightweight_bloc/lightweight_bloc.dart';

import 'log_section_state.dart';

class LogSectionBloc extends Bloc<LogSectionState> {
  @override
  void init() {}

  @override
  LogSectionState get initialState => LogSectionState();

  void addLog(String log) {
    if (log?.isNotEmpty == true) {
      if (log.endsWith('\n')) log = log.substring(0, log.length - 1);
      if (log.startsWith('\n')) log = log.substring(1);
      update(state.copyWith(logs: List.from(state.logs ?? [])..add(log)));
    }
  }
}
