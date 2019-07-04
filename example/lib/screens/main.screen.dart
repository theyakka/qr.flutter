import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'content_widget.dart';

/// The main screen of the application. This is the screen you see when the
/// app starts.
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainState>(
      builder: (_) => MainState(),
      child: Scaffold(
        body: SafeArea(
          child: ContentWidget(),
        ),
        resizeToAvoidBottomPadding: true,
      ),
    );
  }
}

/// The partnering state class for MainScreen
class MainState with ChangeNotifier {
  /// QR text
  String _text = "";

  String get text => _text;

  set text(String s) {
    _text = s;
    notifyListeners();
  }

  /// QR error correction level
  int _errorCorrectionLevel = QrErrorCorrectLevel.L;

  int get errorCorrectionLevel => _errorCorrectionLevel;

  String get errorCorrectionString =>
      QrErrorCorrectLevel.getName(_errorCorrectionLevel);

  increaseErrorCorrectionLevel() {
    switch (_errorCorrectionLevel) {
      case QrErrorCorrectLevel.L:
        _errorCorrectionLevel = QrErrorCorrectLevel.M;
        break;
      case QrErrorCorrectLevel.M:
        _errorCorrectionLevel = QrErrorCorrectLevel.Q;
        break;
      case QrErrorCorrectLevel.Q:
        _errorCorrectionLevel = QrErrorCorrectLevel.H;
        break;
      case QrErrorCorrectLevel.H:
      default:
        _errorCorrectionLevel = QrErrorCorrectLevel.L;
    }

    notifyListeners();
  }

  /// QR gapless
  bool _gapless = true;

  bool get gapless => _gapless;

  void toggleGapless() {
    _gapless = !_gapless;
    notifyListeners();
  }
}
