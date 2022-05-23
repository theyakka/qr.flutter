import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void saveData(List<int> data, String filename) async {
  const platform = MethodChannel("app.yakka.example/dirChannel");
  final result = await platform.invokeMapMethod("getDownloads");
  if (result != null) {
    String absPath = result["absPath"];
    if (!absPath.endsWith("/")) {
      absPath += "/";
    }
    if (kDebugMode) {
      print(absPath);
    }
    String path = "$absPath$filename";
    final file = File(path);
    try {
      await file.writeAsBytes(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
