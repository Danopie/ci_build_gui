import 'package:lightweight_bloc/lightweight_bloc.dart';

class BashState {
  static const STATE_LOADING = "STATE_LOADING";
  static const STATE_BUSY = "STATE_BUSY";
  static const STATE_IDLE = "STATE_IDLE";
  final String state;

  BashState({
    this.state,
  });

  BashState copyWith({
    String state,
  }) {
    return new BashState(
      state: state ?? this.state,
    );
  }
}

class BashBloc extends Bloc<BashState> {
  @override
  void init() {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  BashState get initialState => BashState(state: BashState.STATE_LOADING);
}
