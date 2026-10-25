import 'package:flutter/material.dart';

/// Semantic icon names keep UI usage independent from the chosen icon pack.
abstract final class AppIcons {
  static const back = Icons.arrow_back_rounded;
  static const appearance = Icons.palette_rounded;
  static const playback = Icons.play_circle_rounded;
  static const library = Icons.folder_copy_rounded;
  static const advancedSettings = Icons.settings_applications_rounded;

  static const selected = Icons.check;
  static const colorPicker = Icons.colorize;
  static const folder = Icons.folder;
  static const close = Icons.close;
  static const add = Icons.add;
  static const rescan = Icons.sync_rounded;
  static const delete = Icons.delete_forever;
}
