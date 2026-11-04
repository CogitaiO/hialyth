import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.pageSurface,
    required this.titleBarSurface,
    required this.cardSurface,
    required this.surfaceSubtle,
    required this.surfaceFaint,
    required this.surfaceHover,
    required this.surfaceDisabled,
    required this.surfaceTooltip,
    required this.surfaceOverlay,
    required this.videoSurface,
    required this.borderFaint,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textSubtle,
    required this.textDisabled,
    required this.success,
    required this.info,
    required this.destructive,
    required this.windowCloseHover,
  });

  const AppThemeExtension.dark()
      : pageSurface = const Color(0xFF0F0F0F),
        titleBarSurface = const Color(0xFF151515),
        cardSurface = const Color(0xFF1A1A1A),
        surfaceSubtle = const Color(0x0DFFFFFF),
        surfaceFaint = const Color(0x08FFFFFF),
        surfaceHover = const Color(0x1AFFFFFF),
        surfaceDisabled = Colors.white24,
        surfaceTooltip = Colors.black87,
        surfaceOverlay = Colors.black26,
        videoSurface = Colors.black,
        borderFaint = Colors.white10,
        borderSubtle = Colors.white12,
        borderStrong = Colors.white24,
        textPrimary = Colors.white,
        textSecondary = Colors.white70,
        textMuted = Colors.white54,
        textSubtle = Colors.white38,
        textDisabled = Colors.white24,
        success = Colors.green,
        info = Colors.blueAccent,
        destructive = Colors.redAccent,
        windowCloseHover = const Color(0xFFE81123);

  final Color pageSurface;
  final Color titleBarSurface;
  final Color cardSurface;
  final Color surfaceSubtle;
  final Color surfaceFaint;
  final Color surfaceHover;
  final Color surfaceDisabled;
  final Color surfaceTooltip;
  final Color surfaceOverlay;
  final Color videoSurface;
  final Color borderFaint;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textSubtle;
  final Color textDisabled;
  final Color success;
  final Color info;
  final Color destructive;
  final Color windowCloseHover;

  /// Scrims share one base color so video overlays and poster shading stay consistent.
  Color scrim(double opacity) => Colors.black.withValues(alpha: opacity);

  @override
  AppThemeExtension copyWith({
    Color? pageSurface,
    Color? titleBarSurface,
    Color? cardSurface,
    Color? surfaceSubtle,
    Color? surfaceFaint,
    Color? surfaceHover,
    Color? surfaceDisabled,
    Color? surfaceTooltip,
    Color? surfaceOverlay,
    Color? videoSurface,
    Color? borderFaint,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textSubtle,
    Color? textDisabled,
    Color? success,
    Color? info,
    Color? destructive,
    Color? windowCloseHover,
  }) {
    return AppThemeExtension(
      pageSurface: pageSurface ?? this.pageSurface,
      titleBarSurface: titleBarSurface ?? this.titleBarSurface,
      cardSurface: cardSurface ?? this.cardSurface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceFaint: surfaceFaint ?? this.surfaceFaint,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      surfaceTooltip: surfaceTooltip ?? this.surfaceTooltip,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      videoSurface: videoSurface ?? this.videoSurface,
      borderFaint: borderFaint ?? this.borderFaint,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textSubtle: textSubtle ?? this.textSubtle,
      textDisabled: textDisabled ?? this.textDisabled,
      success: success ?? this.success,
      info: info ?? this.info,
      destructive: destructive ?? this.destructive,
      windowCloseHover: windowCloseHover ?? this.windowCloseHover,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;

    return AppThemeExtension(
      pageSurface: Color.lerp(pageSurface, other.pageSurface, t)!,
      titleBarSurface: Color.lerp(titleBarSurface, other.titleBarSurface, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceFaint: Color.lerp(surfaceFaint, other.surfaceFaint, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceDisabled: Color.lerp(
        surfaceDisabled,
        other.surfaceDisabled,
        t,
      )!,
      surfaceTooltip: Color.lerp(surfaceTooltip, other.surfaceTooltip, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      videoSurface: Color.lerp(videoSurface, other.videoSurface, t)!,
      borderFaint: Color.lerp(borderFaint, other.borderFaint, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      windowCloseHover: Color.lerp(
        windowCloseHover,
        other.windowCloseHover,
        t,
      )!,
    );
  }
}

extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}

/// Shared spacing scale. Semantic aliases match the original layout values;
/// numeric aliases cover the remaining 2px steps.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double s6 = 6;
  static const double xs = 8;
  static const double s10 = 10;
  static const double sm = 12;
  static const double s14 = 14;
  static const double md = 16;
  static const double s20 = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s50 = 50;
  static const double s64 = 64;
}

/// Shared corner radii; [pill] is used for fully rounded surfaces.
abstract final class AppRadii {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}
