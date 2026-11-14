import 'dart:io';

abstract final class ShowcaseStorage {
  static const preferencesPrefix = 'hialyth_showcase_';
  static const databaseDirectoryName = 'hialyth_showcase';

  static String databasePath(String applicationSupportDirectory) =>
      '$applicationSupportDirectory${Platform.pathSeparator}$databaseDirectoryName';
}
