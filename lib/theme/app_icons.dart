import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Semantic icon names keep the UI independent of the icon family.
///
/// Iconsax exposes two variants in this package: the base constants are Bold
/// (filled) and the `_copy` suffix is Linear (outlined). Primary actions and
/// active states use Bold; navigation, secondary actions, and passive states
/// use Linear. To swap icon families, edit only this file.
abstract final class AppIcons {
  static const back = Iconsax.arrow_left_copy;
  static const close = Iconsax.close_circle_copy;
  static const search = Iconsax.search_normal_copy;
  static const settings = Iconsax.setting_2_copy;
  static const sort = Iconsax.sort_copy;
  static const list = Iconsax.row_vertical_copy;
  static const more = Iconsax.more_copy;
  static const dropdown = Iconsax.arrow_down_1_copy;

  static const all = Iconsax.category_copy;
  static const watching = Iconsax.play_circle_copy;
  static const planned = Iconsax.clock_copy;
  static const completed = Iconsax.tick_circle_copy;
  static const dropped = Iconsax.close_circle_copy;
  static const collections = Iconsax.folder_favorite_copy;
  static const addFolder = Iconsax.folder_add_copy;
  static const folder = Iconsax.folder_copy;
  static const folderOpen = Iconsax.folder_open_copy;
  static const movie = Iconsax.video_copy;
  static const appLogo = Iconsax.video_play;
  static const videoLibrary = Iconsax.video_square_copy;
  static const playlist = Iconsax.music_playlist_copy;
  static const image = Iconsax.image_copy;
  static const imageSearch = Iconsax.search_normal_copy;
  static const imageMissing = Iconsax.gallery_slash_copy;
  static const imageBroken = Iconsax.gallery_slash_copy;
  static const fileFormat = Iconsax.cpu_copy;

  static const play = Iconsax.play;
  static const pause = Iconsax.pause;
  static const replay = Iconsax.repeat_circle;
  static const next = Iconsax.next;
  static const skipForward = Iconsax.forward;
  static const volumeOff = Iconsax.volume_slash;
  static const volumeDown = Iconsax.volume_low;
  static const volumeUp = Iconsax.volume_high;
  static const subtitles = Iconsax.subtitle;
  static const audio = Iconsax.musicnote_copy;
  static const pip = Iconsax.copy;
  static const fullscreen = Iconsax.maximize;
  static const playCircle = Iconsax.play_circle;
  static const playCircleOutline = Iconsax.play_circle_copy;
  static const pauseCircle = Iconsax.pause_circle;
  static const checkCircle = Iconsax.tick_circle;
  static const checkCircleOutline = Iconsax.tick_circle_copy;
  static const circleOutline = Iconsax.record_copy;

  static const add = Iconsax.add;
  static const edit = Iconsax.edit_2_copy;
  static const editNote = Iconsax.note_1_copy;
  static const delete = Iconsax.trash_copy;
  static const check = Iconsax.check;
  static const doneAll = Iconsax.tick_square_copy;
  static const stats = Iconsax.chart_2_copy;
  static const notes = Iconsax.note_2_copy;
  static const collectionAdd = Iconsax.bookmark_copy;
  static const openExternal = Iconsax.export_copy;
  static const shield = Iconsax.shield;

  static const minimize = Iconsax.minus_copy;
  static const maximize = Iconsax.maximize_copy;
  static const restore = Iconsax.copy_copy;

  static const appearance = Iconsax.colorfilter_copy;
  static const playback = Iconsax.play_circle_copy;
  static const library = Iconsax.folder_2_copy;
  static const advancedSettings = Iconsax.setting_4_copy;
  static const selected = Iconsax.check;
  static const colorPicker = Iconsax.color_swatch_copy;
  static const rescan = Iconsax.refresh_copy;
}
