import 'package:meta/meta.dart';

@immutable
class LogSectionState {
  final List<String> logs;

  LogSectionState({this.logs});

  LogSectionState copyWith({
    List<String> logs,
  }) {
    return LogSectionState(
      logs: logs ?? this.logs,
    );
  }
}
