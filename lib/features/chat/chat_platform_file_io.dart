import 'dart:io';

import 'package:flutter/widgets.dart';

bool chatLocalFileExistsImpl(String path) => File(path).existsSync();

int chatLocalFileSizeImpl(String path) => File(path).lengthSync();

void chatDeleteLocalFileImpl(String path) {
  try {
    File(path).deleteSync();
  } catch (_) {}
}

Widget chatBuildLocalImageImpl(
  String path, {
  double height = 200,
  BoxFit fit = BoxFit.cover,
}) {
  return Image.file(
    File(path),
    height: height,
    width: double.infinity,
    fit: fit,
  );
}
