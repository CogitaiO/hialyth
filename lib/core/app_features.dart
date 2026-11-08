abstract final class AppFeatures {
  /// Optional presentation: theme, resume feature, ambient tint and glass.
  /// `--dart-define=designV2=false` provides a simpler opaque presentation.
  /// Functional fixes, accessibility and responsive layouts remain active.
  static const bool designV2 = bool.fromEnvironment(
    'designV2',
    defaultValue: true,
  );
}
