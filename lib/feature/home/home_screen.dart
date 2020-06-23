import 'package:example_flutter/feature/config_dialog/build_config.dart';
import 'package:example_flutter/feature/log_section/log_section.dart';
import 'package:example_flutter/helper/widget/circular_loading.dart';
import 'package:example_flutter/helper/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart';

import 'home_bloc.dart';
import 'home_state.dart';

const double _padding = 24;
final _controlBackgroundColor = Colors.white.withAlpha(150);

class HomeScreen extends StatefulWidget {
  static Widget newInstance() {
    return BlocProvider<HomeBloc>(
      builder: (context) => HomeBloc(),
      child: HomeScreen(),
    );
  }

  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocWidgetBuilder<HomeBloc, HomeState>(
      builder: (context, bloc, state) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              lylyBackground(),
              Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 16, bottom: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: BuildConfigSection(
                                    bloc: bloc,
                                    state: state,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                BuildButton(bloc, state),
                              ],
                            ),
                          ),
                        ),
                        Expanded(flex: 2, child: Container()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LogSection.newInstance(bloc),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget lylyBackground() {
    return Image.asset(
      "lyly_bg.jpg",
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );
  }
}

class BackgroundSection extends StatelessWidget {
  final HomeState state;

  const BackgroundSection({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: this.state is HomeBuildingState
            ? [Color(0xFFf45c43), Color(0xFFeb3349)]
            : [Color(0xff825934), Color(0xff825934), Color(0xff0f0c0b)],
      )),
      alignment: Alignment.centerLeft,
    );
  }
}

class BuildButton extends StatelessWidget {
  final HomeBloc bloc;
  final HomeState state;

  BuildButton(this.bloc, this.state);

  @override
  Widget build(BuildContext context) {
    final busy = isServerBusy(state);

    final title = busy
        ? Icon(
            Icons.clear,
            color: Colors.red,
          )
        : Icon(
            Icons.build,
            color: Colors.white,
          );
    final gradientColor = busy
        ? const [Colors.white, Colors.white]
        : const <Color>[
            Color(0xFFF9D976),
            Color(0xFFF39F86),
          ];
    return LayoutBuilder(
      builder: (context, constraint) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CircularLoading(
              enabled: busy,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              child: HomeButton(
                height: 50,
                width: !busy ? constraint.maxWidth : 50,
                child: title,
                gradientColors: gradientColor,
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  bloc.requestBuild();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class BuildConfigSection extends StatelessWidget {
  final HomeBloc bloc;
  final HomeState state;

  const BuildConfigSection({Key key, this.bloc, this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final busy = isServerBusy(state);
    return IgnorePointer(
      ignoring: busy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: Container()),
          _buildBranchTextField(context, bloc, state),
          const SizedBox(height: 12),
          _buildModeDropdown(bloc, state),
          const SizedBox(height: 12),
          Wrap(
            direction: Axis.horizontal,
            runSpacing: 12,
            spacing: 12,
            children: [
              buildCheckBox("Android", state.buildConfig.needAndroid, (value) {
                bloc.onUserChangedNeedAndroid(value);
              }),
              buildCheckBox("iOS", state.buildConfig.needIOS, (value) {
                bloc.onUserChangedNeedIOS(value);
              }),
              buildCheckBox("Pub Get", state.buildConfig.needPackagesGet,
                  (value) {
                bloc.onUserChangedPubGet(value);
              }),
              buildCheckBox("Refresh Native",
                  state.buildConfig.needRefreshNavtiveLibraries, (value) {
                bloc.onUserChangedRefreshNative(value);
              }),
            ],
          ),
        ],
      ),
    );
  }

  static const hintStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );
  Widget _buildBranchTextField(
      BuildContext context, HomeBloc bloc, HomeState state) {
    return Material(
      elevation: 4,
      color: _controlBackgroundColor,
      borderRadius: BorderRadius.circular(_padding),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              textAlign: TextAlign.left,
              onChanged: (str) {
                bloc.onUserInputFlutterModuleBranch(str);
              },
              decoration: InputDecoration(
                disabledBorder: InputBorder.none,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: "Flutter Module Branch",
                hintStyle: hintStyle,
              ),
              maxLines: 1,
            ),
            TextField(
              textAlign: TextAlign.left,
              onChanged: (str) {
                bloc.onUserInputAndroidModuleBranch(str);
              },
              decoration: InputDecoration(
                disabledBorder: InputBorder.none,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: "Android Module Branch",
                hintStyle: hintStyle,
              ),
              maxLines: 1,
            ),
            TextField(
              textAlign: TextAlign.left,
              onChanged: (str) {
                bloc.onUserInputIOSModuleBranch(str);
              },
              decoration: InputDecoration(
                disabledBorder: InputBorder.none,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: "iOS Module Branch",
                hintStyle: hintStyle,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeDropdown(HomeBloc bloc, HomeState state) {
    return Material(
      elevation: 4,
      color: _controlBackgroundColor,
      borderRadius: BorderRadius.circular(_padding),
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<BuildMode>(
          isExpanded: true,
          value: state.buildConfig.mode,
          items: BuildMode.values
              .map((bm) => DropdownMenuItem<BuildMode>(
                    value: bm,
                    child: Text(
                      _getBuildModelTitle(bm),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          selectedItemBuilder: (context) => BuildMode.values
              .map((bm) => Container(
                    padding: EdgeInsets.only(left: 36),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _getBuildModelTitle(bm),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (newValue) {
            bloc.onUserChangedBuildMode(newValue);
          },
        ),
      ),
    );
  }

  String _getBuildModelTitle(BuildMode bm) {
    final str = bm.toString();
    final dotIndex = str.indexOf(("."));
    return str.substring(dotIndex + 1, str.length);
  }
}
