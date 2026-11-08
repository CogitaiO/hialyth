abstract final class AppFeatures {
  /// Enable the design-system theme during the gradual widget migration.
  /// Override with `--dart-define=designV2=false` to use the legacy Material theme.
  static const bool designV2 = bool.fromEnvironment(
    'designV2',
    defaultValue: true,
  );
}
