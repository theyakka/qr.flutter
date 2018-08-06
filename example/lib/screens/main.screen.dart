import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => new _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  String _dataString = "Hello from this QR code!";
  String _inputErrorText;
  final TextEditingController _textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _contentWidget(),
      resizeToAvoidBottomPadding: true,
    );
  }

  @override
  didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return new Container(
      color: const Color(0xFFFFFFFF),
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child: new Container(
              height: _topSectionHeight,
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      controller: _textController,
                      decoration: new InputDecoration(
                        hintText: "Enter a custom message",
                        errorText: _inputErrorText,
                      ),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: new FlatButton(
                      child: new Text("SUBMIT"),
                      onPressed: () {
                        setState(() {
                          _dataString = _textController.text;
                          _inputErrorText = null;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          new Expanded(
            child: new Center(
              child: new QrImage(
                data: _dataString,
                onError: (ex) {
                  print("[QR] ERROR - $ex");
                  setState(() {
                    _inputErrorText =
                        "Error! Maybe your input value is too long?";
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
