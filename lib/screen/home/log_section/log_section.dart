import 'package:example_flutter/screen/home/bloc.dart';
import 'package:example_flutter/screen/home/log_section/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogSection extends StatefulWidget {
  static Widget newInstance() => BlocProvider<LogSectionBloc>(
        builder: (context) =>
            LogSectionBloc(BlocProvider.of<HomeBloc>(context)),
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
    return BlocBuilder<LogSectionBloc, LogSectionState>(
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration(milliseconds: 100), () {
            scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 180),
                curve: Curves.decelerate);
          });
        });
        return Container(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
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
                  style: TextStyle(fontFamily: "DroidSans", fontSize: 12),
                ));
              },
              itemCount: state.logs.length,
            ),
          ),
        );
      },
    );
  }
}
