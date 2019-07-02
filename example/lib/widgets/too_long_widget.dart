import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ContentTooLongWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 300,
        minHeight: 200,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 100,
                      maxWidth: 200,
                      minHeight: 100,
                      maxHeight: 200,
                    ),
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
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, top: 25),
              child: Text(
                "TOO LONG",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
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
        ),
      ),
    );
  }
}
