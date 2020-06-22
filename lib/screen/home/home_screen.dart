import 'package:example_flutter/helper/widget/gradient_button.dart';
import 'package:example_flutter/model/build_config.dart';
import 'package:example_flutter/screen/home/bloc.dart';
import 'package:example_flutter/screen/home/config_dialog/config_dialog.dart';
import 'package:example_flutter/screen/home/log_section/log_section.dart';
import 'package:example_flutter/screen/main/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart' as lw;

const double _padding = 24;
const int _controlOpacity = 255;

class HomeScreen extends StatefulWidget {
  static Widget newInstance() {
    return BlocProvider<HomeBloc>(
      builder: (context) => HomeBloc(),
      child: lw.BlocProvider(
        builder: (context) => MainBloc(),
        child: HomeScreen(),
      ),
    );
  }

  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    BlocProvider.of<HomeBloc>(context).dispatch(InitBlocEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return lw.BlocWidgetBuilder<MainBloc, MainState>(
      builder: (context, bloc, state) {
        return Scaffold(
          body: Stack(
            children: [
              BackgroundSection(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: [
                        lylyBackground(),
                        CommandColumn(),
                        serverInfo(state),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        TopMenuSection(),
                        Expanded(
                          child: LogSection.newInstance(),
                        ),
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
      height: double.infinity,
      fit: BoxFit.fitHeight,
    );
  }

  Widget serverInfo(MainState state) {
    var message = "";
    if (state?.serverState?.connected == true) {
      message += "Em vẫn thấy anh!";
    } else {
      message += "Anh đâu mất òi?!";
    }
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
            fontFamily: "DroidSans",
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class BackgroundSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 400),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: state is HomeBuildingState
                ? [Color(0xFFf45c43), Color(0xFFeb3349)]
                : [Color(0xff825934), Color(0xff825934), Color(0xff0f0c0b)],
          )),
          alignment: Alignment.centerLeft,
        );
      },
    );
  }
}

class CommandColumn extends StatelessWidget {
  const CommandColumn({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2 - _padding * 2) * 2 / 3,
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
          /*Align(
            alignment: Alignment.centerLeft,
            child: AvatarGlow(
              startDelay: Duration(milliseconds: 1000),
              glowColor: Colors.blue,
              endRadius: 60.0,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: Duration(milliseconds: 100),
              child: Material(
                elevation: 8.0,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: Image.asset(lyLy, fit: BoxFit.contain),
                  radius: 40.0,
                ),
              ),
            ),
          ),*/
          Expanded(child: Container()),
          BuildConfigSection(),
          const SizedBox(height: _padding),
          BuildButton(),
        ],
      ),
    );
  }

  String get lyLy => 'assets/lyly.jpg';
}

class BuildButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final title = state is HomeBuildingState
            ? Icon(
                Icons.clear,
                color: Colors.red,
              )
            : Icon(
                Icons.build,
                color: Colors.white,
              );
        final gradientColor = state is HomeBuildingState
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
                  enabled: state is HomeBuildingState,
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
                        final bloc = BlocProvider.of<HomeBloc>(context);
                        if (state is HomeIdleState) {
                          bloc.dispatch(BuildEvent());
                        } else if (state is HomeBuildingState) {
                          bloc.dispatch(StopBuildEvent());
                        }
                      }),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CircularLoading extends StatefulWidget {
  final bool enabled;

  const CircularLoading({Key key, this.enabled}) : super(key: key);

  @override
  _CircularLoadingState createState() => _CircularLoadingState();
}

class _CircularLoadingState extends State<CircularLoading>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    if (widget.enabled) {
      _controller.forward();
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CircularLoading oldWidget) {
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Container(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          height: 58,
          width: 58),
    );
  }
}

class BuildConfigSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return IgnorePointer(
          ignoring: state is HomeBuildingState,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildBranchTextField(context),
              Container(
                height: _padding,
              ),
//                _buildFlavorDropdown(context),
//                Container(
//                  height: _padding,
//                ),
              _buildModeDropdown(context),
              Container(
                height: _padding,
              ),
              _buildCheckList(context)
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchTextField(BuildContext context) {
    return Material(
      elevation: 4,
      color: Colors.white.withAlpha(_controlOpacity),
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
                  fontFamily: "DroidSans",
                ),
              ),
            ),
            TextField(
                textAlign: TextAlign.left,
                onChanged: (str) {
                  BlocProvider.of<HomeBloc>(context)
                      .dispatch(UpdateBranchEvent(flutterModule: str));
                },
                decoration: InputDecoration(
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: "Flutter Module Branch",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontFamily: "DroidSans",
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ))),
            TextField(
                textAlign: TextAlign.left,
                onChanged: (str) {
                  BlocProvider.of<HomeBloc>(context)
                      .dispatch(UpdateBranchEvent(androidModule: str));
                },
                decoration: InputDecoration(
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: "Android Module Branch",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontFamily: "DroidSans",
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ))),
            TextField(
                textAlign: TextAlign.left,
                onChanged: (str) {
                  BlocProvider.of<HomeBloc>(context)
                      .dispatch(UpdateBranchEvent(iosModule: str));
                },
                decoration: InputDecoration(
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: "iOS Module Branch",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontFamily: "DroidSans",
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ))),
          ],
        ),
      ),
    );
  }

  Widget _buildFlavorDropdown(BuildContext context) {
    final _bloc = BlocProvider.of<HomeBloc>(context);
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _bloc,
      builder: (context, state) {
        return Material(
          elevation: 4,
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              underline: Container(),
              isExpanded: true,
              value: state.buildConfig.flavor,
              items: state.flavors
                  .map((f) => DropdownMenuItem<String>(
                        value: f,
                        child: Text(
                          _getFlavorTitle(f),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontFamily: "DroidSans",
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
              selectedItemBuilder: (context) => state.flavors
                  .map((f) => Text(
                        _getFlavorTitle(f),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontFamily: "DroidSans",
                          fontSize: 14,
                        ),
                      ))
                  .toList(),
              onChanged: (newValue) {
                _bloc.dispatch(UpdateFlavorEvent(flavor: newValue));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeDropdown(BuildContext context) {
    final _bloc = BlocProvider.of<HomeBloc>(context);
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _bloc,
      builder: (context, state) {
        return Material(
          elevation: 4,
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
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
                            fontFamily: "DroidSans",
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
                            fontFamily: "DroidSans",
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (newValue) {
                _bloc.dispatch(UpdateBuildModeEvent(mode: newValue));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckList(BuildContext context) {
    final _bloc = BlocProvider.of<HomeBloc>(context);
    return BlocBuilder<HomeBloc, HomeState>(
        bloc: _bloc,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildCheckBox(context, "Clean", state.buildConfig.needClean,
                  (value) {
                _bloc.dispatch(UpdateNeedCleanEvent(value: value));
              }),
              Container(
                height: _padding,
              ),
              _buildCheckBox(
                  context, "Packages Get", state.buildConfig.needPackagesGet,
                  (value) {
                _bloc.dispatch(UpdatePackagesGetEvent(value: value));
              }),
              Container(
                height: _padding,
              ),
              _buildCheckBox(context, "Refresh Native",
                  state.buildConfig.needRefreshNavtiveLibraries, (value) {
                _bloc.dispatch(UpdateRefreshNativeEvent(value: value));
              }),
            ],
          );
        });
  }

  Widget _buildCheckBox(BuildContext context, String title, bool value,
      Function(bool) onChanged) {
    return Material(
      elevation: 4,
      color: Colors.white,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          onChanged(!value);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: <Widget>[
              CircularCheckBox(
                value: value,
              ),
              Container(
                width: 12,
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "DroidSans",
                  color: Colors.black87,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getBuildModelTitle(BuildMode bm) {
    final str = bm.toString();
    final dotIndex = str.indexOf(("."));
    return str.substring(dotIndex + 1, str.length);
  }

  String _getFlavorTitle(String f) {
    final ch = f[0];
    return "${ch.toUpperCase()}${f.substring(1)}";
  }
}

class Label extends StatelessWidget {
  final String text;

  const Label({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }
}

class CircularCheckBox extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const CircularCheckBox({Key key, this.value, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        height: _padding,
        width: _padding,
        decoration: BoxDecoration(
          color: value ? Color(0xFFF39F86) : null,
          shape: BoxShape.circle,
          border: value ? null : Border.all(color: Colors.black45, width: 1),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              )
            : Container(),
      ),
    );
  }
}

class HomeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode focusNode;

  const HomeTextField({Key key, this.controller, this.hintText, this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Colors.white,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _padding, vertical: 6),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
              disabledBorder: InputBorder.none,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                fontFamily: "DroidSans",
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              )),
        ),
      ),
    );
  }
}

class TopMenuSection extends StatefulWidget {
  @override
  _TopMenuSectionState createState() => _TopMenuSectionState();
}

class _TopMenuSectionState extends State<TopMenuSection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <Widget>[
              Spacer(),
              HomeButton(
                height: 50,
                width: 50,
                onPressed: () async {
                  final result = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return ConfigDialog(
                          devEnvironment: state.buildConfig.devEnvironment,
                        );
                      });
                  if (result != null) {
                    BlocProvider.of<HomeBloc>(context).dispatch(
                        UpdateEnvironmentEvent(devEnvironment: result));
                  }
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
              Container(
                width: 12,
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomeButton extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final Function onPressed;
  final List<Color> gradientColors;

  const HomeButton(
      {Key key,
      this.width,
      this.height,
      this.onPressed,
      this.child,
      this.gradientColors = const <Color>[
        Color(0xFFF9D976),
        Color(0xFFF39F86),
      ]})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedGradientButton(
        height: height,
        width: width,
        splashColor: Color(0xFFF9D976).withOpacity(0.5),
        child: child,
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(50),
        onPressed: onPressed);
  }
}
