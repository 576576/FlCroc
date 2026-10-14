import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_croc/models/models.dart';

/// Converts picked files into [FileItem]s.
///
/// file_picker's `PlatformFile` is an abstract, platform-implemented type that
/// cannot represent a file arriving by drag and drop, so the UI keeps [FileItem]
/// — name, path, size — which is what the send options need anyway.
///
/// Entries without a local path are dropped: croc sends files on disk, and a
/// picker can hand back a blob or a remote URI instead.
Future<List<FileItem>> toFileItems(List<PlatformFile> files) async {
  final items = <FileItem>[];
  for (final file in files) {
    final path = file.path;
    if (path == null || path.isEmpty) continue;
    items.add(
      FileItem(name: file.name, path: path, size: (await file.length()) ?? 0),
    );
  }
  return items;
}

/// Builds a [FileItem] for a path that is already on disk, or returns null when
/// there is no file there.
FileItem? fileItemForPath(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  return FileItem(
    name: path.split(Platform.pathSeparator).last,
    path: path,
    size: file.lengthSync(),
  );
}
