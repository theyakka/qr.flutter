import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/too_long_widget.dart';

/// The primary content holder for the example app main screen
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
    if (_inputErrorText != null) {
      _showErrorSnackbar(context, null);
    }
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
                      style: TextStyle(
                        fontFamily: 'Inconsolata',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter a custom message',
                        errorText: _inputErrorText,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xff8d42f5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FlatButton(
                      highlightColor: const Color(0x118d42f5),
                      splashColor: const Color(0x338d42f5),
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(
                          color: Color(0xff8d42f5),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
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
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
//                child: QrImage(
//                  data: _dataString,
//                  gapless: false,
//                  errorCorrectionLevel: QrErrorCorrectLevel.L,
//                  foregroundColor: const Color(0xFF111111),
//                  errorStateBuilder: (ctx, ex) {
//                    return ContentTooLongWidget();
//                  },
//                ),
                child: ContentTooLongWidget(),
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
      SnackBar(content: Text(_inputErrorText)),
    );
//    }
  }

  void _qrErrHandler(Exception ex) {
    print('[QR] ERROR - $ex');
    setState(() {
      _inputErrorText = "Oops! Content is too long.";
    });
    _showErrorSnackbar(context, ex);
  }
}
