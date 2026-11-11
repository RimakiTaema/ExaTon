import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

/// Asks where to save, then saves. Desktop uses the native save dialog;
/// Android and iOS, which file_selector cannot save on, use the system
/// "save as" document picker. Give [bytes] or a [sourcePath] to copy.
/// Returns where it went, or null when the user cancelled.
Future<String?> saveFileAs(String name, {Uint8List? bytes, String? sourcePath}) async {
  assert((bytes == null) != (sourcePath == null), 'give bytes or sourcePath');
  if (Platform.isAndroid || Platform.isIOS) {
    return FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(data: bytes, sourceFilePath: sourcePath, fileName: name),
    );
  }
  final loc = await getSaveLocation(suggestedName: name);
  if (loc == null) return null;
  if (bytes != null) {
    await File(loc.path).writeAsBytes(bytes);
  } else {
    await File(sourcePath!).copy(loc.path);
  }
  return loc.path;
}
