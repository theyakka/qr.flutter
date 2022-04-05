import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void saveData(List<int> data, String filename) async {
  const platform = MethodChannel("app.yakka.example/dirChannel");
  final result = await platform.invokeMapMethod("getDownloads");
  if (result != null) {
    String absPath = result["absPath"];
    String path = "$absPath/$filename";
    final file = File(path);
    try {
      await file.writeAsBytes(data);
    } catch (e) {
      print(e);
    }
  }
}
