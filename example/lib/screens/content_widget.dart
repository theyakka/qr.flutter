import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_demo/screens/simple_options_screen.dart';
import 'package:flutter_qr_demo/widgets/option_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/too_long_widget.dart';

/// The primary content holder for the example app main screen
class ContentWidget extends StatefulWidget {
  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  static const double _entryRowHeight = 70.0;

  final _optionsScreenKey = GlobalKey<SimpleOptionsScreenState>();

  String _dataString = 'Hello from this QR code!';
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();
  List<Widget> _stackChildren;

  @override
  void initState() {
    _stackChildren = <Widget>[_qrContent()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_stackChildren.length > 1) {
          _popOptionsScreen();
          return false;
        }
        return true;
      },
      child: Stack(
        children: _stackChildren,
      ),
    );
  }

  Widget _qrContent() {
    return SafeArea(
      top: true,
      bottom: true,
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Color(0xff8d42f5),
              child: Column(
                children: <Widget>[
                  _entryRow(),
                  _optionsRow(),
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
                    data: _dataString,
                    gapless: false,
                    errorCorrectionLevel: QrErrorCorrectLevel.L,
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
      ),
    );
  }

  Widget _entryRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 20),
      child: Container(
        height: _entryRowHeight,
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
                  errorText: _inputErrorText,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                height: 50,
                child: FlatButton(
                  color: const Color(0x11FFFFFF),
                  highlightColor: const Color(0x11FFFFFF),
                  splashColor: const Color(0x33FFFFFF),
                  child: const Text(
                    'MAKE IT',
                    style: TextStyle(
                      color: Color(0xFFeaff00),
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _optionsRow() {
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
              title: 'VERSION',
              value: 'Auto',
              onTapped: _showOptions,
            ),
            OptionButton(
              imageAssetName: 'assets/images/ic_error_correct.png',
              title: 'ERROR CORRECTION',
              value: 'Low',
              onTapped: _showOptions,
            ),
          ],
        ),
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

  void _showOptions() {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _stackChildren.add(SimpleOptionsScreen(key: _optionsScreenKey));
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: const Color(0xff8d42f5),
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    });
  }

  void _qrErrHandler(Exception ex) {
    print('[QR] ERROR - $ex');
    setState(() {
      _inputErrorText = "Oops! Content is too long.";
    });
    _showErrorSnackbar(context, ex);
  }

  /// Pop the options screen (animate out and remove from the stack).
  void _popOptionsScreen() {
    _optionsScreenKey.currentState.toggle(callback: () {
      setState(() {
        _stackChildren.removeLast();
      });
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }
}
