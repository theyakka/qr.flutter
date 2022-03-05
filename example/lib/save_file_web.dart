import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import "dart:html" as html;

void saveData(List<int> data, String filename) {
  final base64 = base64Encode(data);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = "data:image/png;base64,$base64"
    ..style.display = 'none'
    ..download = filename;
  html.document.body?.children.add(anchor);
  anchor.click();
}
