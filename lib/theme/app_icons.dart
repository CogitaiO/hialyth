import 'package:flutter/material.dart';

/// Semantic icon names keep the UI independent of the icon family.
///
/// Primary actions use filled rounded icons; navigation, secondary actions,
/// and passive states use outlined variants. To swap icon families, edit only
/// this file.
abstract final class AppIcons {
  static const back = Icons.arrow_back_rounded;
  static const close = Icons.close_rounded;
  static const search = Icons.search_rounded;
  static const settings = Icons.settings_outlined;
  static const more = Icons.more_horiz_rounded;
  static const dropdown = Icons.arrow_drop_down_rounded;

  static const all = Icons.all_inclusive_rounded;
  static const watching = Icons.play_circle_outline_rounded;
  static const planned = Icons.watch_later_rounded;
  static const completed = Icons.check_circle_outline_rounded;
  static const dropped = Icons.cancel_outlined;
  static const collections = Icons.folder_special_outlined;
  static const addFolder = Icons.create_new_folder_rounded;
  static const folder = Icons.folder_rounded;
  static const folderOpen = Icons.folder_open_rounded;
  static const movie = Icons.movie_creation_rounded;
  static const appLogo = Icons.movie_filter_rounded;
  static const videoLibrary = Icons.video_library_rounded;
  static const playlist = Icons.format_list_bulleted_rounded;
  static const image = Icons.image_rounded;
  static const imageSearch = Icons.image_search_rounded;
  static const imageMissing = Icons.image_not_supported_rounded;
  static const imageBroken = Icons.heart_broken_rounded;
  static const fileFormat = Icons.memory_rounded;

  static const play = Icons.play_arrow_rounded;
  static const pause = Icons.pause_rounded;
  static const replay = Icons.replay_rounded;
  static const next = Icons.skip_next_rounded;
  static const skipForward = Icons.fast_forward_rounded;
  static const volumeOff = Icons.volume_off_rounded;
  static const volumeDown = Icons.volume_down_rounded;
  static const volumeUp = Icons.volume_up_rounded;
  static const subtitles = Icons.subtitles_rounded;
  static const audio = Icons.audiotrack_rounded;
  static const pip = Icons.picture_in_picture_alt_rounded;
  static const fullscreen = Icons.fullscreen_rounded;
  static const playCircle = Icons.play_circle_fill_rounded;
  static const playCircleOutline = Icons.play_circle_outline_rounded;
  static const pauseCircle = Icons.pause_circle_filled_rounded;
  static const checkCircle = Icons.check_circle_rounded;
  static const checkCircleOutline = Icons.check_circle_outline_rounded;
  static const circleOutline = Icons.radio_button_unchecked_rounded;

  static const add = Icons.add_rounded;
  static const edit = Icons.edit_rounded;
  static const editNote = Icons.edit_note_rounded;
  static const delete = Icons.delete_outline_rounded;
  static const check = Icons.check_rounded;
  static const doneAll = Icons.done_all_rounded;
  static const stats = Icons.bar_chart_rounded;
  static const notes = Icons.sticky_note_2_rounded;
  static const collectionAdd = Icons.bookmark_add_rounded;
  static const openExternal = Icons.open_in_new_rounded;
  static const shield = Icons.shield_outlined;

  static const minimize = Icons.minimize_rounded;
  static const maximize = Icons.crop_square_rounded;
  static const restore = Icons.filter_none_rounded;

  static const appearance = Icons.palette_rounded;
  static const playback = Icons.play_circle_rounded;
  static const library = Icons.folder_copy_rounded;
  static const advancedSettings = Icons.settings_applications_rounded;
  static const selected = Icons.check_rounded;
  static const colorPicker = Icons.colorize_rounded;
  static const rescan = Icons.sync_rounded;
}
