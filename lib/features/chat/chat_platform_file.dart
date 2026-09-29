import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import 'chat_platform_file_stub.dart'
    if (dart.library.io) 'chat_platform_file_io.dart';

/// Cross-platform helpers — `dart:io` must not be used on web.
bool chatLocalFileExists(String? path) {
  if (kIsWeb || path == null || path.isEmpty) return false;
  return chatLocalFileExistsImpl(path);
}

int chatLocalFileSize(String? path) {
  if (kIsWeb || path == null || path.isEmpty) return 0;
  return chatLocalFileSizeImpl(path);
}

void chatDeleteLocalFile(String? path) {
  if (kIsWeb || path == null || path.isEmpty) return;
  chatDeleteLocalFileImpl(path);
}

bool chatIsNetworkOrBlobPath(String? path) {
  if (path == null || path.isEmpty) return false;
  return path.startsWith('blob:') ||
      path.startsWith('http://') ||
      path.startsWith('https://');
}

Widget chatBuildLocalImage(
  String? path, {
  double height = 200,
  BoxFit fit = BoxFit.cover,
  required Widget placeholder,
}) {
  if (path == null || path.isEmpty) return placeholder;

  if (chatIsNetworkOrBlobPath(path)) {
    return Image.network(
      path,
      height: height,
      width: double.infinity,
      fit: fit,
      errorBuilder: (_, _, _) => placeholder,
    );
  }

  if (kIsWeb) return placeholder;

  if (chatLocalFileExists(path)) {
    return chatBuildLocalImageImpl(path, height: height, fit: fit);
  }

  return placeholder;
}
