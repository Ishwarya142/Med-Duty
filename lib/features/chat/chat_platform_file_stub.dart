import 'package:flutter/widgets.dart';

bool chatLocalFileExistsImpl(String path) => false;

int chatLocalFileSizeImpl(String path) => 0;

void chatDeleteLocalFileImpl(String path) {}

Widget chatBuildLocalImageImpl(
  String path, {
  double height = 200,
  BoxFit fit = BoxFit.cover,
}) {
  return const SizedBox.shrink();
}
