import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nekaido'**
  String get appTitle;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryAllTitles.
  ///
  /// In en, this message translates to:
  /// **'All titles'**
  String get libraryAllTitles;

  /// No description provided for @libraryWatching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get libraryWatching;

  /// No description provided for @libraryPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get libraryPlanned;

  /// No description provided for @libraryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get libraryCompleted;

  /// No description provided for @libraryDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get libraryDropped;

  /// No description provided for @libraryCollections.
  ///
  /// In en, this message translates to:
  /// **'My collections'**
  String get libraryCollections;

  /// No description provided for @librarySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get librarySettings;

  /// No description provided for @libraryModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mode: Anime\n(Click to switch)'**
  String get libraryModeTooltip;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get librarySearchHint;

  /// No description provided for @libraryNoCollections.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any collections yet'**
  String get libraryNoCollections;

  /// No description provided for @libraryNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get libraryNothingFound;

  /// No description provided for @libraryAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get libraryAddFolder;

  /// No description provided for @libraryScanningFolder.
  ///
  /// In en, this message translates to:
  /// **'Scanning folder...'**
  String get libraryScanningFolder;

  /// No description provided for @libraryFolderAdded.
  ///
  /// In en, this message translates to:
  /// **'Folder added to library'**
  String get libraryFolderAdded;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your collection will appear here'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a folder with anime — Hialyth will scan the files and create your media library. Videos stay on your computer.'**
  String get libraryEmptyBody;

  /// No description provided for @libraryNoFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'No videos found in this folder'**
  String get libraryNoFilesTitle;

  /// No description provided for @libraryNoFilesBody.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: .mkv, .mp4, .avi. Check the folder or run scan again.'**
  String get libraryNoFilesBody;

  /// No description provided for @libraryNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String libraryNoResultsTitle(Object query);

  /// No description provided for @libraryNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Change your query or reset filters.'**
  String get libraryNoResultsBody;

  /// No description provided for @libraryDatabaseError.
  ///
  /// In en, this message translates to:
  /// **'Database error: {error}'**
  String libraryDatabaseError(Object error);

  /// No description provided for @networkRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Network recommendation'**
  String get networkRecommendationTitle;

  /// No description provided for @networkRecommendationBody.
  ///
  /// In en, this message translates to:
  /// **'Hialyth uses the external services Shikimori and AniSkip to load posters, descriptions, and skip timestamps.\n\nSome providers may block these services in certain regions.\n\nIf you experience errors or endless loading, enable a VPN (for example, with routing for specific IPs) or another workaround.'**
  String get networkRecommendationBody;

  /// No description provided for @networkRecommendationGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get networkRecommendationGotIt;

  /// No description provided for @detailsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue from episode {episode}'**
  String detailsContinue(Object episode);

  /// No description provided for @detailsTitleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Title not found'**
  String get detailsTitleNotFound;

  /// No description provided for @detailsEpisodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Episode {episode}'**
  String detailsEpisodeNumber(Object episode);

  /// No description provided for @detailsEpisodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get detailsEpisodesLabel;

  /// No description provided for @detailsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String detailsError(Object error);

  /// No description provided for @detailsCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get detailsCollection;

  /// No description provided for @detailsInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get detailsInformation;

  /// No description provided for @detailsAdded.
  ///
  /// In en, this message translates to:
  /// **'Added:'**
  String get detailsAdded;

  /// No description provided for @detailsWatchedLabel.
  ///
  /// In en, this message translates to:
  /// **'Watched:'**
  String get detailsWatchedLabel;

  /// No description provided for @detailsWatchTime.
  ///
  /// In en, this message translates to:
  /// **'Watch time:'**
  String get detailsWatchTime;

  /// No description provided for @detailsFolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder:'**
  String get detailsFolderLabel;

  /// No description provided for @detailsTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get detailsTitleField;

  /// No description provided for @detailsPosterUrl.
  ///
  /// In en, this message translates to:
  /// **'Poster URL'**
  String get detailsPosterUrl;

  /// No description provided for @detailsNewCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get detailsNewCollection;

  /// No description provided for @detailsChooseCollection.
  ///
  /// In en, this message translates to:
  /// **'Or choose an existing collection'**
  String get detailsChooseCollection;

  /// No description provided for @detailsChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Select from computer'**
  String get detailsChooseImage;

  /// No description provided for @detailsSyncingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Looking up data for \"{title}\"...'**
  String detailsSyncingMetadata(Object title);

  /// No description provided for @detailsMetadataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully!'**
  String get detailsMetadataUpdated;

  /// No description provided for @detailsShikimoriNoData.
  ///
  /// In en, this message translates to:
  /// **'Unable to find data on Shikimori'**
  String get detailsShikimoriNoData;

  /// No description provided for @detailsHours.
  ///
  /// In en, this message translates to:
  /// **'~{hours} hours'**
  String detailsHours(Object hours);

  /// No description provided for @detailsMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get detailsMoreOptions;

  /// No description provided for @detailsOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get detailsOptions;

  /// No description provided for @detailsOpenFolderInManager.
  ///
  /// In en, this message translates to:
  /// **'Open folder in file manager'**
  String get detailsOpenFolderInManager;

  /// No description provided for @detailsReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get detailsReplay;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @dialogAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dialogAdd;

  /// No description provided for @detailsPlayFromStart.
  ///
  /// In en, this message translates to:
  /// **'Start from episode 1'**
  String get detailsPlayFromStart;

  /// No description provided for @detailsRewatch.
  ///
  /// In en, this message translates to:
  /// **'Rewatch'**
  String get detailsRewatch;

  /// No description provided for @detailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get detailsStatus;

  /// No description provided for @detailsEpisodes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode} other{{count} episodes}}'**
  String detailsEpisodes(num count);

  /// No description provided for @detailsFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get detailsFormat;

  /// No description provided for @detailsFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get detailsFolder;

  /// No description provided for @detailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailsDescription;

  /// No description provided for @detailsReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get detailsReadMore;

  /// No description provided for @detailsNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available yet'**
  String get detailsNoDescription;

  /// No description provided for @detailsUpdateFromNetwork.
  ///
  /// In en, this message translates to:
  /// **'Update from network'**
  String get detailsUpdateFromNetwork;

  /// No description provided for @detailsWatched.
  ///
  /// In en, this message translates to:
  /// **'{watched, plural, =1{1 watched} other{{watched} watched}} of {total, plural, =1{1 episode} other{{total} episodes}}'**
  String detailsWatched(num total, num watched);

  /// No description provided for @detailsNoEpisodes.
  ///
  /// In en, this message translates to:
  /// **'No episodes found in this folder'**
  String get detailsNoEpisodes;

  /// No description provided for @detailsOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get detailsOpenFolder;

  /// No description provided for @detailsScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get detailsScanAgain;

  /// No description provided for @detailsMissingFile.
  ///
  /// In en, this message translates to:
  /// **'File missing'**
  String get detailsMissingFile;

  /// No description provided for @detailsMarkWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark as watched'**
  String get detailsMarkWatched;

  /// No description provided for @detailsMarkUnwatched.
  ///
  /// In en, this message translates to:
  /// **'Mark as unwatched'**
  String get detailsMarkUnwatched;

  /// No description provided for @detailsOpenFileLocation.
  ///
  /// In en, this message translates to:
  /// **'Open file location'**
  String get detailsOpenFileLocation;

  /// No description provided for @detailsRemoveFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get detailsRemoveFromLibrary;

  /// No description provided for @detailsRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from library?'**
  String detailsRemoveConfirmTitle(Object title);

  /// No description provided for @detailsRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the title from Hialyth. Video files on your computer are not deleted.'**
  String get detailsRemoveConfirmBody;

  /// No description provided for @detailsMarkAllWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark all as watched'**
  String get detailsMarkAllWatched;

  /// No description provided for @detailsEditPoster.
  ///
  /// In en, this message translates to:
  /// **'Edit poster'**
  String get detailsEditPoster;

  /// No description provided for @detailsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get detailsEditTitle;

  /// No description provided for @detailsStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get detailsStatistics;

  /// No description provided for @playerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get playerLoading;

  /// No description provided for @playerNextEpisodePrompt.
  ///
  /// In en, this message translates to:
  /// **'Next episode starts in...'**
  String get playerNextEpisodePrompt;

  /// No description provided for @playerMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get playerMenu;

  /// No description provided for @playerEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get playerEpisodes;

  /// No description provided for @playerNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get playerNotes;

  /// No description provided for @playerPlaylistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Playlist is empty'**
  String get playerPlaylistEmpty;

  /// No description provided for @playerLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get playerLoadingError;

  /// No description provided for @playerEpisodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Episode {episode}'**
  String playerEpisodeNumber(Object episode);

  /// No description provided for @playerVideoRequiredForNotes.
  ///
  /// In en, this message translates to:
  /// **'Select a video to add notes'**
  String get playerVideoRequiredForNotes;

  /// No description provided for @playerAddNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note to the current frame...'**
  String get playerAddNoteHint;

  /// No description provided for @playerErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String playerErrorDetail(Object error);

  /// No description provided for @playerNoNotes.
  ///
  /// In en, this message translates to:
  /// **'There are no notes for this series'**
  String get playerNoNotes;

  /// No description provided for @playerNoTracks.
  ///
  /// In en, this message translates to:
  /// **'No tracks available'**
  String get playerNoTracks;

  /// No description provided for @playerTrackAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get playerTrackAuto;

  /// No description provided for @playerTrackOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get playerTrackOff;

  /// No description provided for @playerBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get playerBack;

  /// No description provided for @playerSpeedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get playerSpeedNormal;

  /// No description provided for @playerDubsSubs.
  ///
  /// In en, this message translates to:
  /// **'Dubs & Subs'**
  String get playerDubsSubs;

  /// No description provided for @playerReturnToPlayer.
  ///
  /// In en, this message translates to:
  /// **'Return to player'**
  String get playerReturnToPlayer;

  /// No description provided for @playerResumeFrom.
  ///
  /// In en, this message translates to:
  /// **'Resumed from {time}'**
  String playerResumeFrom(Object time);

  /// No description provided for @playerStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get playerStartOver;

  /// No description provided for @playerNextEpisodeIn.
  ///
  /// In en, this message translates to:
  /// **'Next episode in {seconds}s'**
  String playerNextEpisodeIn(Object seconds);

  /// No description provided for @playerWatchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch now'**
  String get playerWatchNow;

  /// No description provided for @playerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get playerCancel;

  /// No description provided for @playerNextEpisode.
  ///
  /// In en, this message translates to:
  /// **'Next episode'**
  String get playerNextEpisode;

  /// No description provided for @playerEpisodeComplete.
  ///
  /// In en, this message translates to:
  /// **'Episode complete'**
  String get playerEpisodeComplete;

  /// No description provided for @playerSeriesComplete.
  ///
  /// In en, this message translates to:
  /// **'You\'ve watched the last episode'**
  String get playerSeriesComplete;

  /// No description provided for @playerReturnToTitle.
  ///
  /// In en, this message translates to:
  /// **'Return to title'**
  String get playerReturnToTitle;

  /// No description provided for @playerRewatchSeries.
  ///
  /// In en, this message translates to:
  /// **'Rewatch series'**
  String get playerRewatchSeries;

  /// No description provided for @playerPlayPause.
  ///
  /// In en, this message translates to:
  /// **'Play/Pause'**
  String get playerPlayPause;

  /// No description provided for @playerMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get playerMute;

  /// No description provided for @playerVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get playerVolume;

  /// No description provided for @playerSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get playerSpeed;

  /// No description provided for @playerAudioTracks.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get playerAudioTracks;

  /// No description provided for @playerSubtitleTracks.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get playerSubtitleTracks;

  /// No description provided for @playerPictureInPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture in Picture'**
  String get playerPictureInPicture;

  /// No description provided for @playerEpisodesNotes.
  ///
  /// In en, this message translates to:
  /// **'Episodes & Notes'**
  String get playerEpisodesNotes;

  /// No description provided for @playerFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get playerFullscreen;

  /// No description provided for @playerSeekBackward.
  ///
  /// In en, this message translates to:
  /// **'Seek backward 5s'**
  String get playerSeekBackward;

  /// No description provided for @playerSeekForward.
  ///
  /// In en, this message translates to:
  /// **'Seek forward 5s'**
  String get playerSeekForward;

  /// No description provided for @playerSkipOpening.
  ///
  /// In en, this message translates to:
  /// **'Skip opening'**
  String get playerSkipOpening;

  /// No description provided for @playerSkipEnding.
  ///
  /// In en, this message translates to:
  /// **'Skip ending'**
  String get playerSkipEnding;

  /// No description provided for @playerErrorFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get playerErrorFileNotFound;

  /// No description provided for @playerErrorFileNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The video file could not be found:\n{path}\n\nIt may have been moved or deleted.'**
  String playerErrorFileNotFoundBody(Object path);

  /// No description provided for @playerErrorFileNotFoundReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get playerErrorFileNotFoundReturn;

  /// No description provided for @playerErrorFileNotFoundDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get playerErrorFileNotFoundDelete;

  /// No description provided for @playerErrorDecode.
  ///
  /// In en, this message translates to:
  /// **'Playback error'**
  String get playerErrorDecode;

  /// No description provided for @playerErrorDecodeBody.
  ///
  /// In en, this message translates to:
  /// **'Failed to open the video file.\n{error}'**
  String playerErrorDecodeBody(Object error);

  /// No description provided for @playerErrorDecodeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get playerErrorDecodeRetry;

  /// No description provided for @playerErrorDecodeSettings.
  ///
  /// In en, this message translates to:
  /// **'Decoder settings'**
  String get playerErrorDecodeSettings;

  /// No description provided for @playerErrorDecodeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get playerErrorDecodeBack;

  /// No description provided for @playerNoAudioTrack.
  ///
  /// In en, this message translates to:
  /// **'No audio track'**
  String get playerNoAudioTrack;

  /// No description provided for @playerNoSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles unavailable'**
  String get playerNoSubtitles;

  /// No description provided for @playerProgressSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save progress'**
  String get playerProgressSaveFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsPlayback;

  /// No description provided for @settingsLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get settingsLibrary;

  /// No description provided for @settingsIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get settingsIntegrations;

  /// No description provided for @settingsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeColors.
  ///
  /// In en, this message translates to:
  /// **'Theme & Colors'**
  String get settingsThemeColors;

  /// No description provided for @settingsReduceTransparencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Disable blur and use solid surfaces in the player.'**
  String get settingsReduceTransparencyDescription;

  /// No description provided for @settingsAppAccentColor.
  ///
  /// In en, this message translates to:
  /// **'App Accent Color'**
  String get settingsAppAccentColor;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get settingsAccentColor;

  /// No description provided for @settingsCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get settingsCustomColor;

  /// No description provided for @settingsReducedTransparency.
  ///
  /// In en, this message translates to:
  /// **'Reduce transparency'**
  String get settingsReducedTransparency;

  /// No description provided for @settingsReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReducedMotion;

  /// No description provided for @settingsInterfaceDensity.
  ///
  /// In en, this message translates to:
  /// **'Interface density'**
  String get settingsInterfaceDensity;

  /// No description provided for @settingsDensityComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get settingsDensityComfortable;

  /// No description provided for @settingsDensityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get settingsDensityCompact;

  /// No description provided for @settingsAutoSkip.
  ///
  /// In en, this message translates to:
  /// **'Auto-skip opening/ending'**
  String get settingsAutoSkip;

  /// No description provided for @settingsAutoSkipDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically skip if AniSkip finds timestamps'**
  String get settingsAutoSkipDescription;

  /// No description provided for @settingsLanguagePriority.
  ///
  /// In en, this message translates to:
  /// **'Languages (Priority)'**
  String get settingsLanguagePriority;

  /// No description provided for @settingsAudioJapaneseOriginal.
  ///
  /// In en, this message translates to:
  /// **'Japanese (Original)'**
  String get settingsAudioJapaneseOriginal;

  /// No description provided for @settingsAudioEnglishDub.
  ///
  /// In en, this message translates to:
  /// **'English (Dub)'**
  String get settingsAudioEnglishDub;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsVideoDecoder.
  ///
  /// In en, this message translates to:
  /// **'Video Decoder'**
  String get settingsVideoDecoder;

  /// No description provided for @settingsHardwareAccelerationDescription.
  ///
  /// In en, this message translates to:
  /// **'Change this if video is lagging or shows a black screen'**
  String get settingsHardwareAccelerationDescription;

  /// No description provided for @settingsDecoderAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsDecoderAuto;

  /// No description provided for @settingsDecoderAutoSafe.
  ///
  /// In en, this message translates to:
  /// **'Auto (Safe)'**
  String get settingsDecoderAutoSafe;

  /// No description provided for @settingsDecoderWindowsD3d11va.
  ///
  /// In en, this message translates to:
  /// **'Windows (d3d11va)'**
  String get settingsDecoderWindowsD3d11va;

  /// No description provided for @settingsDecoderDisabledCpu.
  ///
  /// In en, this message translates to:
  /// **'Disabled (CPU)'**
  String get settingsDecoderDisabledCpu;

  /// No description provided for @settingsAutoplayNext.
  ///
  /// In en, this message translates to:
  /// **'Autoplay next episode'**
  String get settingsAutoplayNext;

  /// No description provided for @settingsResumePlayback.
  ///
  /// In en, this message translates to:
  /// **'Resume playback'**
  String get settingsResumePlayback;

  /// No description provided for @settingsAudioPriority.
  ///
  /// In en, this message translates to:
  /// **'Audio language priority'**
  String get settingsAudioPriority;

  /// No description provided for @settingsSubtitlePriority.
  ///
  /// In en, this message translates to:
  /// **'Subtitle language priority'**
  String get settingsSubtitlePriority;

  /// No description provided for @settingsHardwareAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Hardware acceleration'**
  String get settingsHardwareAcceleration;

  /// No description provided for @settingsDecoder.
  ///
  /// In en, this message translates to:
  /// **'Decoder'**
  String get settingsDecoder;

  /// No description provided for @settingsDiscordRpc.
  ///
  /// In en, this message translates to:
  /// **'Discord Rich Presence'**
  String get settingsDiscordRpc;

  /// No description provided for @settingsDiscordRpcDescription.
  ///
  /// In en, this message translates to:
  /// **'Show the anime you are watching in your Discord status'**
  String get settingsDiscordRpcDescription;

  /// No description provided for @settingsDiscordRpcEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Discord Rich Presence'**
  String get settingsDiscordRpcEnabled;

  /// No description provided for @settingsShikimoriStatus.
  ///
  /// In en, this message translates to:
  /// **'Shikimori status'**
  String get settingsShikimoriStatus;

  /// No description provided for @settingsAniskipStatus.
  ///
  /// In en, this message translates to:
  /// **'AniSkip status'**
  String get settingsAniskipStatus;

  /// No description provided for @settingsCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check connection'**
  String get settingsCheckConnection;

  /// No description provided for @settingsConnectionNote.
  ///
  /// In en, this message translates to:
  /// **'Services may be unavailable in some regions without VPN.'**
  String get settingsConnectionNote;

  /// No description provided for @settingsFolders.
  ///
  /// In en, this message translates to:
  /// **'Library folders'**
  String get settingsFolders;

  /// No description provided for @settingsNoFolders.
  ///
  /// In en, this message translates to:
  /// **'No folders added yet'**
  String get settingsNoFolders;

  /// No description provided for @settingsFolderQueued.
  ///
  /// In en, this message translates to:
  /// **'Folder added to scan queue'**
  String get settingsFolderQueued;

  /// No description provided for @settingsAddNewFolder.
  ///
  /// In en, this message translates to:
  /// **'Add New Folder'**
  String get settingsAddNewFolder;

  /// No description provided for @settingsScanStarted.
  ///
  /// In en, this message translates to:
  /// **'Scan started...'**
  String get settingsScanStarted;

  /// No description provided for @settingsScanCompleted.
  ///
  /// In en, this message translates to:
  /// **'Scan completed!'**
  String get settingsScanCompleted;

  /// No description provided for @settingsRescanLibrary.
  ///
  /// In en, this message translates to:
  /// **'Rescan Library'**
  String get settingsRescanLibrary;

  /// No description provided for @settingsAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get settingsAddFolder;

  /// No description provided for @settingsScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan now'**
  String get settingsScanNow;

  /// No description provided for @settingsRemoveFolder.
  ///
  /// In en, this message translates to:
  /// **'Remove from sources'**
  String get settingsRemoveFolder;

  /// No description provided for @settingsLastScan.
  ///
  /// In en, this message translates to:
  /// **'Last scan: {time}'**
  String settingsLastScan(Object time);

  /// No description provided for @settingsTitlesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 title} other{{count} titles}}'**
  String settingsTitlesCount(num count);

  /// No description provided for @settingsClearImageCache.
  ///
  /// In en, this message translates to:
  /// **'Clear image cache'**
  String get settingsClearImageCache;

  /// No description provided for @settingsClearDatabase.
  ///
  /// In en, this message translates to:
  /// **'Clear database'**
  String get settingsClearDatabase;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// No description provided for @settingsClearDatabaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Removes all titles, watch history, and notes. Media files on disk will NOT be deleted.'**
  String get settingsClearDatabaseDescription;

  /// No description provided for @settingsClearDatabaseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear database?'**
  String get settingsClearDatabaseConfirmTitle;

  /// No description provided for @settingsClearDatabaseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all titles, progress, notes, and collections from Hialyth. Video files on your computer are NOT deleted.'**
  String get settingsClearDatabaseConfirmBody;

  /// No description provided for @settingsClearDatabaseButton.
  ///
  /// In en, this message translates to:
  /// **'Clear database'**
  String get settingsClearDatabaseButton;

  /// No description provided for @settingsLogsFolder.
  ///
  /// In en, this message translates to:
  /// **'Open logs folder'**
  String get settingsLogsFolder;

  /// No description provided for @settingsCacheSize.
  ///
  /// In en, this message translates to:
  /// **'Cache size: {size}'**
  String settingsCacheSize(Object size);

  /// No description provided for @settingsDatabaseSize.
  ///
  /// In en, this message translates to:
  /// **'Database size: {size}'**
  String settingsDatabaseSize(Object size);

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get settingsCommit;

  /// No description provided for @settingsPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get settingsPlatform;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// No description provided for @dialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDelete;

  /// No description provided for @dialogRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get dialogRemove;

  /// No description provided for @dialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// No description provided for @settingsApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get settingsApply;

  /// No description provided for @dialogEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dialogEdit;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// No description provided for @dialogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOk;

  /// No description provided for @dialogRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dialogRetry;

  /// No description provided for @toastCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get toastCopied;

  /// No description provided for @toastAddedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Added to collection'**
  String get toastAddedToCollection;

  /// No description provided for @toastRemovedFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Removed from collection'**
  String get toastRemovedFromCollection;

  /// No description provided for @statusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlanned;

  /// No description provided for @statusWatching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get statusWatching;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @timeShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String timeShort(Object minutes, Object seconds);

  /// No description provided for @timeLong.
  ///
  /// In en, this message translates to:
  /// **'{hours}:{minutes}:{seconds}'**
  String timeLong(Object hours, Object minutes, Object seconds);

  /// No description provided for @fileSizeBytes.
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String fileSizeBytes(Object bytes);

  /// No description provided for @fileSizeKb.
  ///
  /// In en, this message translates to:
  /// **'{kb} KB'**
  String fileSizeKb(Object kb);

  /// No description provided for @fileSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{mb} MB'**
  String fileSizeMb(Object mb);

  /// No description provided for @fileSizeGb.
  ///
  /// In en, this message translates to:
  /// **'{gb} GB'**
  String fileSizeGb(Object gb);

  /// No description provided for @settingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibility;

  /// No description provided for @settingsReduceMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Use instant transitions and remove decorative motion.'**
  String get settingsReduceMotionDescription;

  /// No description provided for @libraryTitleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 title} other{{count} titles}}'**
  String libraryTitleCount(num count);

  /// No description provided for @libraryClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get libraryClearSearch;

  /// No description provided for @libraryResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get libraryResetFilters;

  /// No description provided for @libraryNavigation.
  ///
  /// In en, this message translates to:
  /// **'Library navigation'**
  String get libraryNavigation;

  /// No description provided for @libraryBrowse.
  ///
  /// In en, this message translates to:
  /// **'Your local anime collection'**
  String get libraryBrowse;

  /// No description provided for @libraryScanError.
  ///
  /// In en, this message translates to:
  /// **'Unable to scan the folder. Check access and try again.'**
  String get libraryScanError;

  /// No description provided for @libraryMetadataWarning.
  ///
  /// In en, this message translates to:
  /// **'Local files imported. Some online metadata could not be loaded.'**
  String get libraryMetadataWarning;

  /// No description provided for @commonSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save. Check the title for duplicates and try again.'**
  String get commonSaveFailed;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @playerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this video'**
  String get playerLoadFailed;

  /// No description provided for @playerLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check that the file is available and can be decoded, then try again.'**
  String get playerLoadFailedBody;

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to start the application'**
  String get startupFailed;

  /// No description provided for @startupFailedBody.
  ///
  /// In en, this message translates to:
  /// **'The media engine or local library could not be opened. Check the log for details and try again.'**
  String get startupFailedBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
