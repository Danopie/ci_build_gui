import 'package:meta/meta.dart';

@immutable
abstract class LogSectionEvent {}

class UpdateLogEvent extends LogSectionEvent {
  final String log;

  UpdateLogEvent(this.log);
}

class ClearLogEvent extends LogSectionEvent {}
