import 'package:example_flutter/feature/config_dialog/build_config.dart';
import 'package:example_flutter/feature/log_section/log_section.dart';
import 'package:example_flutter/helper/widget/circular_loading.dart';
import 'package:example_flutter/helper/widget_utils.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: CommandColumn(
                      bloc: bloc,
                      state: state,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: LogSection.newInstance(),
                        ),
                        BuildButton(bloc, state),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget lylyBackground() {
    return Image.network(
      "https://ss-images.catscdn.vn/wp700/2020/03/04/7100023/81963578_2506845056082028_5294172470838820864_o.jpg",
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    );
  }

  Widget serverInfo(HomeState state) {
    var message = "";
//    if (state?.serverState?.connected == true) {
//      message += "Em vẫn thấy anh!";
//    } else {
//      message += "Anh đâu mất òi?!";
//    }
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.only(top: 30, right: 16),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
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

class CommandColumn extends StatelessWidget {
  final HomeBloc bloc;
  final HomeState state;
  const CommandColumn({Key key, this.bloc, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: _padding),
            child: Text(
              "LyLy",
              style: TextStyle(
                  fontFamily: "Vegan",
                  fontSize: 30,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black12, offset: Offset(0, 3))
                  ]),
            ),
          ),
          Expanded(child: SizedBox()),
          BuildConfigSection(
            bloc: bloc,
            state: state,
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  String get lyLy => 'assets/lyly.jpg';
}

class BuildButton extends StatelessWidget {
  final HomeBloc bloc;
  final HomeState state;

  BuildButton(this.bloc, this.state);

  @override
  Widget build(BuildContext context) {
    final busy = state.serverBash?.busy == true;

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
                width: state is HomeIdleState ? constraint.maxWidth : 50,
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
    return IgnorePointer(
      ignoring: state?.serverBash?.busy == true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildBranchTextField(bloc, state),
          Container(
            height: _padding,
          ),
          _buildModeDropdown(bloc, state),
          Container(
            height: _padding,
          ),
          _buildCheckList(bloc, state),
        ],
      ),
    );
  }

  Widget _buildBranchTextField(HomeBloc bloc, HomeState state) {
    return Material(
      elevation: 4,
      color: _controlBackgroundColor,
      borderRadius: BorderRadius.circular(_padding),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 12),
              child: Text(
                "Branches",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
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
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ))),
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
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ))),
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
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ))),
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

  Widget _buildCheckList(HomeBloc bloc, HomeState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildCheckBox("Pub Get", state.buildConfig.needPackagesGet, (value) {
          bloc.onUserChangedPubGet(value);
        }),
        Container(
          height: _padding,
        ),
        buildCheckBox(
            "Refresh Native", state.buildConfig.needRefreshNavtiveLibraries,
            (value) {
          bloc.onUserChangedRefreshNative(value);
        }),
      ],
    );
  }

  String _getBuildModelTitle(BuildMode bm) {
    final str = bm.toString();
    final dotIndex = str.indexOf(("."));
    return str.substring(dotIndex + 1, str.length);
  }
}