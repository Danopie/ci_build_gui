import 'dart:async';

import 'package:clippy/browser.dart' as clippy;
import 'package:example_flutter/feature/home/home_bloc.dart';
import 'package:example_flutter/feature/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart';

import 'log_section_bloc.dart';
import 'log_section_state.dart';

class LogSection extends StatefulWidget {
  static Widget newInstance(HomeBloc homeBloc) => BlocProvider<LogSectionBloc>(
        builder: (context) => LogSectionBloc(),
        child: LogSection(),
      );

  const LogSection({
    Key key,
  }) : super(key: key);

  @override
  _LogSectionState createState() => _LogSectionState();
}

class _LogSectionState extends State<LogSection> {
  final scrollController = ScrollController();
  static const logTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.white,
  );
  @override
  Widget build(BuildContext context) {
    return BlocWidgetBuilder<LogSectionBloc, LogSectionState>(
      builder: (context, bloc, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration(milliseconds: 100), () {
            scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 180),
                curve: Curves.decelerate);
          });
        });

        return BlocListener<HomeBloc, HomeState>(
          listener: (context1, homeBloc, homeState) {
            if (homeState.serverMessage?.data != null &&
                homeState.serverMessage?.data['type'] == 'busy' &&
                homeState.serverMessage?.data['log'] != null) {
              bloc.addLog(homeState.serverMessage?.data['log']);
            } else if (homeState.serverMessage?.message != null) {
              bloc.addLog(homeState.serverMessage?.message);
            }
          },
          child: Container(
            color: Colors.black45,
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              physics: BouncingScrollPhysics(),
              controller: scrollController,
              itemBuilder: (context, index) {
                final textStr = state.logs[index];
                if (textStr.startsWith("https://install.appcenter.ms")) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Material(
                      elevation: 4,
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          // Write to clipboard
                          await clippy.write(textStr);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            textStr,
                            style: logTextStyle,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Text(
                    state.logs[index],
                    style: logTextStyle,
                  );
                }
              },
              itemCount: state.logs?.length ?? 0,
            ),
          ),
        );
      },
    );
  }
}
