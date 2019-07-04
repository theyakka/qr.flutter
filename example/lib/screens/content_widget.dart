import 'package:flutter/material.dart';
import 'package:flutter_qr_demo/screens/main.screen.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';
// import './simple_options_screen.dart';
import '../widgets/option_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/too_long_widget.dart';

/// The primary content holder for the example app main screen
class ContentWidget extends StatefulWidget {
  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Color(0xff8d42f5),
            child: Column(
              children: <Widget>[
                EntryRow(),
                OptionsRow(),
                Divider(
                  color: const Color(0xff5927a1),
                  height: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: QrImage(
                  data: Provider.of<MainState>(context).text,
                  gapless: Provider.of<MainState>(context).gapless,
                  errorCorrectionLevel:
                      Provider.of<MainState>(context).errorCorrectionLevel,
                  foregroundColor: const Color(0xFF111111),
                  constrainErrorBounds: false,
                  errorStateBuilder: (ctx, ex) {
                    return ContentTooLongWidget();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff8d42f5),
      child: Padding(
        padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OptionButton(
              imageAssetName: 'assets/images/ic_version_circle.png',
              title: 'GAPLESS',
              value: Provider.of<MainState>(context).gapless ? "Yes" : "No",
              onTapped: () => Provider.of<MainState>(context).toggleGapless(),
            ),
            OptionButton(
              imageAssetName: 'assets/images/ic_error_correct.png',
              title: 'ERROR CORRECTION',
              value: Provider.of<MainState>(context).errorCorrectionString,
              onTapped: () => Provider.of<MainState>(context)
                  .increaseErrorCorrectionLevel(),
            ),
          ],
        ),
      ),
    );
  }
}

class EntryRow extends StatefulWidget {
  final double entryRowHeight;

  EntryRow({this.entryRowHeight = 70.0});

  @override
  _EntryRowState createState() => _EntryRowState();
}

class _EntryRowState extends State<EntryRow> {
  TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();

    _textController.addListener(() {
      Provider.of<MainState>(context).text = _textController.text;
    });

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 20),
      child: Container(
        height: widget.entryRowHeight,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                controller: _textController,
                style: TextStyle(
                  fontFamily: 'Inconsolata',
                  color: const Color(0xFFFFFFFF),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter a custom message',
                  hintStyle: TextStyle(
                    color: const Color(0xAAFFFFFF),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color(0x55d1b4fa)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xffd1b4fa)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Container(
                height: 50,
                child: FlatButton(
                  color: const Color(0x11FFFFFF),
                  disabledTextColor: Colors.grey,
                  highlightColor: const Color(0x11FFFFFF),
                  splashColor: const Color(0x33FFFFFF),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Color(0xFFeaff00),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: Provider.of<MainState>(context).text.isEmpty
                      ? null
                      : () {
                          _textController.clear();
                        },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
