// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nekaido';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryAllTitles => 'All titles';

  @override
  String get libraryWatching => 'Watching';

  @override
  String get libraryPlanned => 'Planned';

  @override
  String get libraryCompleted => 'Completed';

  @override
  String get libraryDropped => 'Dropped';

  @override
  String get libraryCollections => 'My collections';

  @override
  String get librarySettings => 'Settings';

  @override
  String get libraryModeTooltip => 'Mode: Anime\n(Click to switch)';

  @override
  String get librarySearchHint => 'Search...';

  @override
  String get libraryNoCollections => 'You don\'t have any collections yet';

  @override
  String get libraryNothingFound => 'Nothing found';

  @override
  String get libraryAddFolder => 'Add folder';

  @override
  String get libraryScanningFolder => 'Scanning folder...';

  @override
  String get libraryFolderAdded => 'Folder added to library';

  @override
  String get libraryEmptyTitle => 'Your collection will appear here';

  @override
  String get libraryEmptyBody =>
      'Add a folder with anime — Hialyth will scan the files and create your media library. Videos stay on your computer.';

  @override
  String get libraryNoFilesTitle => 'No videos found in this folder';

  @override
  String get libraryNoFilesBody =>
      'Supported formats: .mkv, .mp4, .avi. Check the folder or run scan again.';

  @override
  String libraryNoResultsTitle(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get libraryNoResultsBody => 'Change your query or reset filters.';

  @override
  String libraryDatabaseError(Object error) {
    return 'Database error: $error';
  }

  @override
  String get networkRecommendationTitle => 'Network recommendation';

  @override
  String get networkRecommendationBody =>
      'Hialyth uses the external services Shikimori and AniSkip to load posters, descriptions, and skip timestamps.\n\nSome providers may block these services in certain regions.\n\nIf you experience errors or endless loading, enable a VPN (for example, with routing for specific IPs) or another workaround.';

  @override
  String get networkRecommendationGotIt => 'Got it';

  @override
  String detailsContinue(Object episode) {
    return 'Continue from episode $episode';
  }

  @override
  String get detailsTitleNotFound => 'Title not found';

  @override
  String detailsEpisodeNumber(Object episode) {
    return 'Episode $episode';
  }

  @override
  String get detailsEpisodesLabel => 'Episodes';

  @override
  String detailsError(Object error) {
    return 'Error: $error';
  }

  @override
  String get detailsCollection => 'Collection';

  @override
  String get detailsInformation => 'Information';

  @override
  String get detailsAdded => 'Added:';

  @override
  String get detailsWatchedLabel => 'Watched:';

  @override
  String get detailsWatchTime => 'Watch time:';

  @override
  String get detailsFolderLabel => 'Folder:';

  @override
  String get detailsTitleField => 'Title';

  @override
  String get detailsPosterUrl => 'Poster URL';

  @override
  String get detailsNewCollection => 'New collection';

  @override
  String get detailsChooseCollection => 'Or choose an existing collection';

  @override
  String get detailsChooseImage => 'Select from computer';

  @override
  String detailsSyncingMetadata(Object title) {
    return 'Looking up data for \"$title\"...';
  }

  @override
  String get detailsMetadataUpdated => 'Data updated successfully!';

  @override
  String get detailsShikimoriNoData => 'Unable to find data on Shikimori';

  @override
  String detailsHours(Object hours) {
    return '~$hours hours';
  }

  @override
  String get detailsMoreOptions => 'More options';

  @override
  String get detailsOptions => 'Options';

  @override
  String get detailsOpenFolderInManager => 'Open folder in file manager';

  @override
  String get detailsReplay => 'Replay';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get dialogAdd => 'Add';

  @override
  String get detailsPlayFromStart => 'Start from episode 1';

  @override
  String get detailsRewatch => 'Rewatch';

  @override
  String get detailsStatus => 'Status';

  @override
  String detailsEpisodes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String get detailsFormat => 'Format';

  @override
  String get detailsFolder => 'Folder';

  @override
  String get detailsDescription => 'Description';

  @override
  String get detailsReadMore => 'Read more';

  @override
  String get detailsNoDescription => 'No description available yet';

  @override
  String get detailsUpdateFromNetwork => 'Update from network';

  @override
  String detailsWatched(num total, num watched) {
    String _temp0 = intl.Intl.pluralLogic(
      watched,
      locale: localeName,
      other: '$watched watched',
      one: '1 watched',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total episodes',
      one: '1 episode',
    );
    return '$_temp0 of $_temp1';
  }

  @override
  String get detailsNoEpisodes => 'No episodes found in this folder';

  @override
  String get detailsOpenFolder => 'Open folder';

  @override
  String get detailsScanAgain => 'Scan again';

  @override
  String get detailsMissingFile => 'File missing';

  @override
  String get detailsMarkWatched => 'Mark as watched';

  @override
  String get detailsMarkUnwatched => 'Mark as unwatched';

  @override
  String get detailsOpenFileLocation => 'Open file location';

  @override
  String get detailsRemoveFromLibrary => 'Remove from library';

  @override
  String detailsRemoveConfirmTitle(Object title) {
    return 'Remove \"$title\" from library?';
  }

  @override
  String get detailsRemoveConfirmBody =>
      'This removes the title from Hialyth. Video files on your computer are not deleted.';

  @override
  String get detailsMarkAllWatched => 'Mark all as watched';

  @override
  String get detailsEditPoster => 'Edit poster';

  @override
  String get detailsEditTitle => 'Edit title';

  @override
  String get detailsStatistics => 'Statistics';

  @override
  String get playerLoading => 'Loading...';

  @override
  String get playerNextEpisodePrompt => 'Next episode starts in...';

  @override
  String get playerMenu => 'Menu';

  @override
  String get playerEpisodes => 'Episodes';

  @override
  String get playerNotes => 'Notes';

  @override
  String get playerPlaylistEmpty => 'Playlist is empty';

  @override
  String get playerLoadingError => 'Loading error';

  @override
  String playerEpisodeNumber(Object episode) {
    return 'Episode $episode';
  }

  @override
  String get playerVideoRequiredForNotes => 'Select a video to add notes';

  @override
  String get playerAddNoteHint => 'Add a note to the current frame...';

  @override
  String playerErrorDetail(Object error) {
    return 'Error: $error';
  }

  @override
  String get playerNoNotes => 'There are no notes for this series';

  @override
  String get playerNoTracks => 'No tracks available';

  @override
  String get playerTrackAuto => 'Auto';

  @override
  String get playerTrackOff => 'Off';

  @override
  String get playerBack => 'Back';

  @override
  String get playerSpeedNormal => 'Normal';

  @override
  String get playerDubsSubs => 'Dubs & Subs';

  @override
  String get playerReturnToPlayer => 'Return to player';

  @override
  String playerResumeFrom(Object time) {
    return 'Resumed from $time';
  }

  @override
  String get playerStartOver => 'Start over';

  @override
  String playerNextEpisodeIn(Object seconds) {
    return 'Next episode in ${seconds}s';
  }

  @override
  String get playerWatchNow => 'Watch now';

  @override
  String get playerCancel => 'Cancel';

  @override
  String get playerNextEpisode => 'Next episode';

  @override
  String get playerEpisodeComplete => 'Episode complete';

  @override
  String get playerSeriesComplete => 'You\'ve watched the last episode';

  @override
  String get playerReturnToTitle => 'Return to title';

  @override
  String get playerRewatchSeries => 'Rewatch series';

  @override
  String get playerPlayPause => 'Play/Pause';

  @override
  String get playerMute => 'Mute';

  @override
  String get playerVolume => 'Volume';

  @override
  String get playerSpeed => 'Speed';

  @override
  String get playerAudioTracks => 'Audio';

  @override
  String get playerSubtitleTracks => 'Subtitles';

  @override
  String get playerPictureInPicture => 'Picture in Picture';

  @override
  String get playerEpisodesNotes => 'Episodes & Notes';

  @override
  String get playerFullscreen => 'Fullscreen';

  @override
  String get playerSeekBackward => 'Seek backward 5s';

  @override
  String get playerSeekForward => 'Seek forward 5s';

  @override
  String get playerSkipOpening => 'Skip opening';

  @override
  String get playerSkipEnding => 'Skip ending';

  @override
  String get playerErrorFileNotFound => 'File not found';

  @override
  String playerErrorFileNotFoundBody(Object path) {
    return 'The video file could not be found:\n$path\n\nIt may have been moved or deleted.';
  }

  @override
  String get playerErrorFileNotFoundReturn => 'Return';

  @override
  String get playerErrorFileNotFoundDelete => 'Remove from library';

  @override
  String get playerErrorDecode => 'Playback error';

  @override
  String playerErrorDecodeBody(Object error) {
    return 'Failed to open the video file.\n$error';
  }

  @override
  String get playerErrorDecodeRetry => 'Retry';

  @override
  String get playerErrorDecodeSettings => 'Decoder settings';

  @override
  String get playerErrorDecodeBack => 'Back';

  @override
  String get playerNoAudioTrack => 'No audio track';

  @override
  String get playerNoSubtitles => 'Subtitles unavailable';

  @override
  String get playerProgressSaveFailed => 'Failed to save progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsLibrary => 'Library';

  @override
  String get settingsIntegrations => 'Integrations';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeColors => 'Theme & Colors';

  @override
  String get settingsReduceTransparencyDescription =>
      'Disable blur and use solid surfaces in the player.';

  @override
  String get settingsAppAccentColor => 'App Accent Color';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsAccentColor => 'Accent color';

  @override
  String get settingsCustomColor => 'Custom color';

  @override
  String get settingsReducedTransparency => 'Reduce transparency';

  @override
  String get settingsReducedMotion => 'Reduce motion';

  @override
  String get settingsInterfaceDensity => 'Interface density';

  @override
  String get settingsDensityComfortable => 'Comfortable';

  @override
  String get settingsDensityCompact => 'Compact';

  @override
  String get settingsAutoSkip => 'Auto-skip opening/ending';

  @override
  String get settingsAutoSkipDescription =>
      'Automatically skip if AniSkip finds timestamps';

  @override
  String get settingsLanguagePriority => 'Languages (Priority)';

  @override
  String get settingsAudioJapaneseOriginal => 'Japanese (Original)';

  @override
  String get settingsAudioEnglishDub => 'English (Dub)';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsVideoDecoder => 'Video Decoder';

  @override
  String get settingsHardwareAccelerationDescription =>
      'Change this if video is lagging or shows a black screen';

  @override
  String get settingsDecoderAuto => 'Auto';

  @override
  String get settingsDecoderAutoSafe => 'Auto (Safe)';

  @override
  String get settingsDecoderWindowsD3d11va => 'Windows (d3d11va)';

  @override
  String get settingsDecoderDisabledCpu => 'Disabled (CPU)';

  @override
  String get settingsAutoplayNext => 'Autoplay next episode';

  @override
  String get settingsResumePlayback => 'Resume playback';

  @override
  String get settingsAudioPriority => 'Audio language priority';

  @override
  String get settingsSubtitlePriority => 'Subtitle language priority';

  @override
  String get settingsHardwareAcceleration => 'Hardware acceleration';

  @override
  String get settingsDecoder => 'Decoder';

  @override
  String get settingsDiscordRpc => 'Discord Rich Presence';

  @override
  String get settingsDiscordRpcDescription =>
      'Show the anime you are watching in your Discord status';

  @override
  String get settingsDiscordRpcEnabled => 'Enable Discord Rich Presence';

  @override
  String get settingsShikimoriStatus => 'Shikimori status';

  @override
  String get settingsAniskipStatus => 'AniSkip status';

  @override
  String get settingsCheckConnection => 'Check connection';

  @override
  String get settingsConnectionNote =>
      'Services may be unavailable in some regions without VPN.';

  @override
  String get settingsFolders => 'Library folders';

  @override
  String get settingsNoFolders => 'No folders added yet';

  @override
  String get settingsFolderQueued => 'Folder added to scan queue';

  @override
  String get settingsAddNewFolder => 'Add New Folder';

  @override
  String get settingsScanStarted => 'Scan started...';

  @override
  String get settingsScanCompleted => 'Scan completed!';

  @override
  String get settingsRescanLibrary => 'Rescan Library';

  @override
  String get settingsAddFolder => 'Add folder';

  @override
  String get settingsScanNow => 'Scan now';

  @override
  String get settingsRemoveFolder => 'Remove from sources';

  @override
  String settingsLastScan(Object time) {
    return 'Last scan: $time';
  }

  @override
  String settingsTitlesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
    );
    return '$_temp0';
  }

  @override
  String get settingsClearImageCache => 'Clear image cache';

  @override
  String get settingsClearDatabase => 'Clear database';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsClearDatabaseDescription =>
      'Removes all titles, watch history, and notes. Media files on disk will NOT be deleted.';

  @override
  String get settingsClearDatabaseConfirmTitle => 'Clear database?';

  @override
  String get settingsClearDatabaseConfirmBody =>
      'This will delete all titles, progress, notes, and collections from Hialyth. Video files on your computer are NOT deleted.';

  @override
  String get settingsClearDatabaseButton => 'Clear database';

  @override
  String get settingsLogsFolder => 'Open logs folder';

  @override
  String settingsCacheSize(Object size) {
    return 'Cache size: $size';
  }

  @override
  String settingsDatabaseSize(Object size) {
    return 'Database size: $size';
  }

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsCommit => 'Commit';

  @override
  String get settingsPlatform => 'Platform';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get dialogRemove => 'Remove';

  @override
  String get dialogSave => 'Save';

  @override
  String get settingsApply => 'Apply';

  @override
  String get dialogEdit => 'Edit';

  @override
  String get dialogClose => 'Close';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogRetry => 'Retry';

  @override
  String get toastCopied => 'Copied';

  @override
  String get toastAddedToCollection => 'Added to collection';

  @override
  String get toastRemovedFromCollection => 'Removed from collection';

  @override
  String get statusPlanned => 'Planned';

  @override
  String get statusWatching => 'Watching';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDropped => 'Dropped';

  @override
  String timeShort(Object minutes, Object seconds) {
    return '$minutes:$seconds';
  }

  @override
  String timeLong(Object hours, Object minutes, Object seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String fileSizeBytes(Object bytes) {
    return '$bytes B';
  }

  @override
  String fileSizeKb(Object kb) {
    return '$kb KB';
  }

  @override
  String fileSizeMb(Object mb) {
    return '$mb MB';
  }

  @override
  String fileSizeGb(Object gb) {
    return '$gb GB';
  }

  @override
  String get settingsAccessibility => 'Accessibility';

  @override
  String get settingsReduceMotionDescription =>
      'Use instant transitions and remove decorative motion.';

  @override
  String libraryTitleCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
    );
    return '$_temp0';
  }

  @override
  String get libraryClearSearch => 'Clear search';

  @override
  String get libraryResetFilters => 'Reset filters';

  @override
  String get libraryNavigation => 'Library navigation';

  @override
  String get libraryBrowse => 'Your local anime collection';

  @override
  String get libraryScanError =>
      'Unable to scan the folder. Check access and try again.';
}
