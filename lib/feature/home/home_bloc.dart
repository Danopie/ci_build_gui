import 'package:example_flutter/feature/config_dialog/build_config.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart';

import 'home_state.dart';

class HomeBloc extends Bloc<HomeState> {
  @override
  void init() {
    // TODO: implement init
  }

  @override
  // TODO: implement initialState
  HomeState get initialState => HomeState(
        buildConfig: BuildConfig.defaultConfig(),
      );
}
