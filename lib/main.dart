// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:example_flutter/gradient_button.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  debugPrint = (str, {wrapWidth}) {};

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // See https://github.com/flutter/flutter/wiki/Desktop-shells#fonts
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final logStrs = <String>[];

  final _scrollController = ScrollController();

  final stdOutController = BehaviorSubject<List<int>>();
  Sink<List<int>> get stdOutSink => stdOutController.sink;

  @override
  void initState() {
    stdOutController.listen((outs) {
      setState(() {
        final str = String.fromCharCodes(outs).trim();
        if (str.isNotEmpty) {
          logStrs.add(str);
        }
      });

      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 180), curve: Curves.decelerate);
      });
    });

    super.initState();
  }

  void _buildApp() async {
    final shell = Shell(stdout: stdOutSink);

    final result = await shell.run('''
      dir
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CommandColumn(
              onBuild: _buildApp,
            ),
            Expanded(
              child: Container(
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  elevation: 8,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                    physics: BouncingScrollPhysics(),
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      return Container(child: SelectableText(logStrs[index], style: TextStyle(fontFamily: "DroidSans", fontSize: 12),));
                    },
                    itemCount: logStrs.length,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class CommandColumn extends StatelessWidget {
  final Function onBuild;

  const CommandColumn({Key key, this.onBuild}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      width: 300,
      child: Column(
        children: <Widget>[
          Text(
            "LyLy",
            style: TextStyle(
                fontFamily: "Vegan",
                fontSize: 30,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black12, offset: Offset(0, 3))]),
          ),
          AvatarGlow(
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
                child: Image.network(lyLy, fit: BoxFit.cover),
                radius: 40.0,
              ),
            ),
          ),
          Spacer(),
          FractionallySizedBox(
            widthFactor: 0.4,
            child: RaisedGradientButton(
                height: 50,
                splashColor: Colors.blue.withOpacity(0.5),
                child: Text(
                  'Build',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                gradient: LinearGradient(
                  colors: const <Color>[
                    Color(0xFFF9D976),
                    Color(0xFFF39F86),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                onPressed: onBuild),
          ),
        ],
      ),
    );
  }

  String get lyLy =>
      'https://instagram.fsgn5-6.fna.fbcdn.net/vp/3101c8d60b953e500c919123ded775b7/5E308933/t51.2885-15/sh0.08/e35/p640x640/49528713_111345003305874_2718678274949548649_n.jpg?_nc_ht=instagram.fsgn5-6.fna.fbcdn.net&_nc_cat=106';
}
