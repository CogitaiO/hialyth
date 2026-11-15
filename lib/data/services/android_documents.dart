import 'dart:io';

import 'package:android_file_picker/android_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class AndroidDocuments {
  static const _channel = MethodChannel('hialyth/android_documents');

  static bool isDocumentUri(String value) =>
      Uri.tryParse(value)?.scheme == 'content';

  static Future<String?> pickFolder() => FilePicker.getDirectoryPath(
    androidOptions: const FilePickerAndroidOptions(
      safOptions: AndroidSAFOptions(grant: AndroidSAFGrant.lifetime),
    ),
  );

  static Future<List<Map<String, String>>> scan(String uri) async {
    final result = await _channel.invokeListMethod<dynamic>('scan', {
      'uri': uri,
    });
    if (result == null) throw StateError('Could not read the selected folder');
    return result.map((item) => Map<String, String>.from(item as Map)).toList();
  }

  static Future<bool> exists(String path) async {
    if (!isDocumentUri(path)) return File(path).exists();
    try {
      return await _channel.invokeMethod<bool>('exists', {'uri': path}) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  static String displayName(String path) {
    if (!isDocumentUri(path)) return File(path).uri.pathSegments.last;
    final segments = Uri.parse(path).pathSegments;
    return segments.isEmpty ? path : segments.last.split('/').last;
  }
}
