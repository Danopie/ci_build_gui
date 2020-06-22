import 'package:example_flutter/helper/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'build_config.dart';

class ConfigDialog extends StatefulWidget {
  final DevEnvironment devEnvironment;

  const ConfigDialog({Key key, this.devEnvironment}) : super(key: key);

  @override
  _ConfigDialogState createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<ConfigDialog> {
  final textControllers = List<TextEditingController>();
  final focusNodes = List<FocusNode>.generate(4, (index) => FocusNode());

  @override
  void initState() {
    textControllers
        .add(TextEditingController(text: widget.devEnvironment.buildFilePath));
    textControllers
        .add(TextEditingController(text: widget.devEnvironment.flutterRoot));
    textControllers
        .add(TextEditingController(text: widget.devEnvironment.androidHome));
    textControllers
        .add(TextEditingController(text: widget.devEnvironment.javaHome));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: HomeTextField(
                    controller: textControllers[0],
                    hintText: "Build file path",
                    focusNode: focusNodes[0],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: HomeTextField(
                    controller: textControllers[1],
                    hintText: "FLUTTER_ROOT",
                    focusNode: focusNodes[1],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: HomeTextField(
                    controller: textControllers[2],
                    hintText: "ANDROID_HOME",
                    focusNode: focusNodes[2],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: HomeTextField(
                    controller: textControllers[3],
                    hintText: "JAVA_HOME",
                    focusNode: focusNodes[3],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    HomeButton(
                      height: 50,
                      width: 50,
                      onPressed: () async {
                        final data = await Clipboard.getData("text/plain");
                        _getInFocusController().text = data.text;
                      },
                      child: Icon(
                        Icons.archive,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 12,
                    ),
                    HomeButton(
                      height: 50,
                      width: 50,
                      onPressed: () async {
                        _getInFocusController().clear();
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    HomeButton(
                      height: 50,
                      width: 100,
                      onPressed: () async {
                        Navigator.of(context).pop(DevEnvironment(
                          buildFilePath: textControllers[0].text,
                          flutterRoot: textControllers[1].text,
                          androidHome: textControllers[2].text,
                          javaHome: textControllers[3].text,
                        ));
                      },
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController _getInFocusController() {
    TextEditingController controller;
    focusNodes.asMap().forEach((index, node) {
      if (node.hasFocus) {
        controller = textControllers[index];
        return;
      }
    });
    return controller;
  }
}
