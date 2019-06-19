import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ContentWidget extends StatefulWidget {
  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  String _dataString = 'Hello from this QR code!';
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 30.0,
              right: 20.0,
              bottom: _topSectionBottomPadding,
            ),
            child: Container(
              height: _topSectionHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Enter a custom message',
                        errorText: _inputErrorText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FlatButton(
                      child: const Text('SUBMIT'),
                      onPressed: () {
                        _showErrorSnackbar(context, null);
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
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: QrImage(
                  data: _dataString,
                  gapless: false,
                  foregroundColor: const Color(0xFF111111),
                  onError: (ex) {
                    print('[QR] ERROR - $ex');
//                    _showErrorSnackbar(context, ex);
//                    setState(() {});
                  },
                ),
//                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext ctx, Exception ex) {
//    if (ex is InputTooLongException) {
//      _inputErrorText = 'Error! Maybe your input value is too long?';
    Scaffold.of(ctx).showSnackBar(
      SnackBar(content: Text("Oops! Content is too long.")),
    );
//    }
  }
}
