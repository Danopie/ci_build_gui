import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lightweight_bloc/lightweight_bloc.dart';

import 'log_section_bloc.dart';
import 'log_section_state.dart';

class LogSection extends StatefulWidget {
  static Widget newInstance() => BlocProvider<LogSectionBloc>(
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
        return Container(
          padding: const EdgeInsets.all(24),
          child: Material(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            elevation: 8,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              physics: BouncingScrollPhysics(),
              controller: scrollController,
              itemBuilder: (context, index) {
                return Container(
                    child: SelectableText(
                  state.logs[index],
                  style: TextStyle(fontSize: 12),
                ));
              },
              itemCount: state.logs?.length ?? 0,
            ),
          ),
        );
      },
    );
  }
}
