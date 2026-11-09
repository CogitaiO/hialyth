import 'package:flutter/material.dart';

/// Typography tokens using Inter for UI and JetBrains Mono for timecodes.
/// Fonts are bundled as variable fonts in assets/fonts/.
abstract final class AppTypography {
  static const String _inter = 'Inter';
  static const String _mono = 'JetBrainsMono';

  /// Display large — 36/44, weight 700. Large title on detail screen (max 2 lines).
  static const TextStyle displayLarge = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 44 / 36,
    letterSpacing: 0,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Display — 32/40, weight 700. Screen headings.
  static const TextStyle display = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: 0,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Headline — 24/32, weight 700. Section headings, empty states.
  static const TextStyle headline = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 0,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Title large — 20/28, weight 600. Dialog titles, panel headers.
  static const TextStyle titleLarge = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 28 / 20,
    letterSpacing: 0.15,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Title — 16/24, weight 600. Card titles, list items.
  static const TextStyle title = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.15,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Body — 14/20, weight 400. Primary body text.
  static const TextStyle body = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Body small — 13/18, weight 400. Secondary descriptions.
  static const TextStyle bodySmall = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 18 / 13,
    letterSpacing: 0.4,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Label — 12/16, weight 600. Buttons, chips, labels.
  static const TextStyle label = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.5,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Caption — 11/16, weight 500. Metadata, tooltips.
  static const TextStyle caption = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _inter,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.4,
    fontFamilyFallback: [_mono, 'Roboto'],
  );

  /// Mono — 13/20, weight 500. Timecodes, file sizes, technical info.
  static const TextStyle mono = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _mono,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 20 / 13,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Mono small — 12/18, weight 500. Inline timecodes.
  static const TextStyle monoSmall = TextStyle(
    inherit: false,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: _mono,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 18 / 12,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Builds a [TextTheme] with all tokens mapped to Material roles.
  static TextTheme textTheme(ColorScheme scheme) => TextTheme(
    displayLarge: displayLarge.copyWith(color: scheme.onSurface),
    displayMedium: display.copyWith(color: scheme.onSurface),
    displaySmall: headline.copyWith(color: scheme.onSurface),
    headlineLarge: headline.copyWith(color: scheme.onSurface),
    headlineMedium: titleLarge.copyWith(color: scheme.onSurface),
    headlineSmall: titleLarge.copyWith(color: scheme.onSurface),
    titleLarge: titleLarge.copyWith(color: scheme.onSurface),
    titleMedium: title.copyWith(color: scheme.onSurface),
    titleSmall: label.copyWith(color: scheme.onSurface),
    bodyLarge: body.copyWith(color: scheme.onSurface),
    bodyMedium: body.copyWith(color: scheme.onSurfaceVariant),
    bodySmall: bodySmall.copyWith(color: scheme.onSurfaceVariant),
    labelLarge: label.copyWith(color: scheme.onSurface),
    labelMedium: label.copyWith(color: scheme.onSurfaceVariant),
    labelSmall: caption.copyWith(color: scheme.onSurfaceVariant),
  );
}