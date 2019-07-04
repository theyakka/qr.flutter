import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shows an error message when you've entered QR code data that won't fit to
/// the QR code spec.
class ContentTooLongWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            minHeight: 120,
            maxHeight: 260,
          ),
          child: _errorContent(),
        ),
      ),
    );
  }

  Widget _errorContent() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Center(child: _errorQrCode()),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.0, top: 25),
          child: Text(
            "TOO MUCH DATA",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 3,
              color: const Color(0xff8d42f5),
            ),
          ),
        ),
        Text(
          "Looks like you're entering a string that is longer than the QR "
          "spec allows. Please use a shorter string.",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _errorQrCode() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        constraints: BoxConstraints.loose(Size(200, 200)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xff8d42f5),
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.7,
            heightFactor: 0.7,
            child: QrImage(
              gapless: true,
              foregroundColor: Colors.white,
              data: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            ),
          ),
        ),
      ),
    );
  }
}
