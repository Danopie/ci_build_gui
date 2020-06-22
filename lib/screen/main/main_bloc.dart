import 'package:example_flutter/repository/socket_repository.dart';
import 'package:example_flutter/screen/main/main_model.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart';

class MainState {
  static const STATE_LOADING = "STATE_LOADING";
  static const STATE_CONNECTED = "STATE_CONNECTED";
  final String state;
  final ServerState serverState;

  MainState({
    this.state,
    this.serverState,
  });

  MainState copyWith({
    String state,
    ServerState serverState,
  }) {
    return new MainState(
      state: state ?? this.state,
      serverState: serverState ?? this.serverState,
    );
  }
}

class MainBloc extends Bloc<MainState> {
  final _socketRepository = SocketRepository();
  @override
  void init() {
    _socketRepository.connect();
    _socketRepository.serverStateStream.listen((event) {
      update(state.copyWith(
        serverState: event,
      ));
    });
    update(state.copyWith(state: MainState.STATE_CONNECTED));
  }

  @override
  void dispose() {
    _socketRepository.disconnect();
    super.dispose();
  }

  @override
  MainState get initialState => MainState(state: MainState.STATE_LOADING);
}
