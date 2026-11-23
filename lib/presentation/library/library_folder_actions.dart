import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/l10n.dart';
import '../../data/services/android_documents.dart';
import '../../providers/scan_provider.dart';
import '../../providers/settings_provider.dart';

Future<void> addLibraryFolder(BuildContext context, WidgetRef ref) async {
  if (ref.read(scanProvider).running) return;
  try {
    final path = Platform.isAndroid
        ? await AndroidDocuments.pickFolder()
        : await FilePicker.getDirectoryPath();
    if (path == null || !context.mounted) return;
    final result = await ref.read(scanProvider.notifier).scan([path]);
    if (!result.cancelled && result.errors.isEmpty) {
      ref.read(savedFoldersProvider.notifier).addFolder(path);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.cancelled
                ? context.l10n.libraryScanCancelled
                : result.errors.isNotEmpty
                ? context.l10n.libraryScanError
                : result.warnings > 0
                ? context.l10n.libraryMetadataWarning
                : context.l10n.libraryFolderAdded,
          ),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.libraryScanError)));
    }
  }
}
