import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'app_surfaces.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.pageSurface,
    required this.titleBarSurface,
    required this.cardSurface,
    required this.container,
    required this.containerHigh,
    required this.hover,
    required this.surfaceSubtle,
    required this.surfaceFaint,
    required this.surfaceHover,
    required this.surfaceDisabled,
    required this.surfaceTooltip,
    required this.surfaceOverlay,
    required this.glass,
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
    required this.warning,
    required this.danger,
    required this.destructive,
    required this.statusPlanned,
    required this.statusWatching,
    required this.statusCompleted,
    required this.statusDropped,
    required this.windowCloseHover,
  });

  /// Dark theme using design contract tokens.
  /// All values are compile-time constants.
  const AppThemeExtension.dark()
      : pageSurface = AppSurfaces.base, // AppSurfaces.base
        titleBarSurface = AppSurfaces.raised, // AppSurfaces.raised
        cardSurface = AppSurfaces.container, // AppSurfaces.container
        container = AppSurfaces.container, // AppSurfaces.container
        containerHigh = AppSurfaces.containerHigh, // AppSurfaces.containerHigh
        hover = AppSurfaces.borderSubtle, // AppSurfaces.hover
        surfaceSubtle = const Color(0x0DFFFFFF), // white 0.05
        surfaceFaint = const Color(0x08FFFFFF), // white 0.03
        surfaceHover = AppSurfaces.borderSubtle, // AppSurfaces.hover
        surfaceDisabled = const Color(0x33FFFFFF), // white 0.2
        surfaceTooltip = AppSurfaces.base, // AppSurfaces.base
        surfaceOverlay = AppSurfaces.overlay, // AppSurfaces.overlay 0.88
        glass = AppSurfaces.glass, // AppSurfaces.glass 0.55
        videoSurface = Colors.black, // AppSurfaces.videoSurface
        borderFaint = AppSurfaces.borderFaint, // white 0.1
        borderSubtle = AppSurfaces.borderSubtle, // AppSurfaces.borderSubtle
        borderStrong = AppSurfaces.borderStrong, // AppSurfaces.borderStrong
        textPrimary = AppSurfaces.contentPrimary, // AppSurfaces.contentPrimary
        textSecondary =
            AppSurfaces.contentSecondary, // AppSurfaces.contentSecondary
        textMuted = AppSurfaces.contentMuted, // AppSurfaces.contentMuted
        textSubtle = AppSurfaces.contentSecondary, // white 0.38
        textDisabled = const Color(0x33FFFFFF), // white 0.2
        success = AppPalette.success, // 0xFF4ADE80
        info = AppPalette.info, // 0xFF60A5FA
        warning = AppPalette.warning, // 0xFFFBBF24
        danger = AppPalette.danger, // 0xFFF87171
        destructive = AppPalette.danger, // alias
        statusPlanned = AppPalette.statusPlanned, // 0xFFC4B5FD
        statusWatching = AppPalette.statusWatching, // 0xFF7DB7FF
        statusCompleted = AppPalette.statusCompleted, // 0xFF6EE7B7
        statusDropped = AppPalette.statusDropped, // 0xFFFCA5A5
        windowCloseHover = AppPalette.windowCloseHover; // 0xFFE81123

  final Color pageSurface;
  final Color titleBarSurface;
  final Color cardSurface;
  final Color container;
  final Color containerHigh;
  final Color hover;
  final Color surfaceSubtle;
  final Color surfaceFaint;
  final Color surfaceHover;
  final Color surfaceDisabled;
  final Color surfaceTooltip;
  final Color surfaceOverlay;
  final Color glass;
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
  final Color warning;
  final Color danger;
  final Color destructive;
  final Color statusPlanned;
  final Color statusWatching;
  final Color statusCompleted;
  final Color statusDropped;
  final Color windowCloseHover;

  /// Scrim for video overlays.
  Color scrim(double opacity) => Colors.black.withValues(alpha: opacity);

  @override
  AppThemeExtension copyWith({
    Color? pageSurface,
    Color? titleBarSurface,
    Color? cardSurface,
    Color? container,
    Color? containerHigh,
    Color? hover,
    Color? surfaceSubtle,
    Color? surfaceFaint,
    Color? surfaceHover,
    Color? surfaceDisabled,
    Color? surfaceTooltip,
    Color? surfaceOverlay,
    Color? glass,
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
    Color? warning,
    Color? danger,
    Color? destructive,
    Color? statusPlanned,
    Color? statusWatching,
    Color? statusCompleted,
    Color? statusDropped,
    Color? windowCloseHover,
  }) {
    return AppThemeExtension(
      pageSurface: pageSurface ?? this.pageSurface,
      titleBarSurface: titleBarSurface ?? this.titleBarSurface,
      cardSurface: cardSurface ?? this.cardSurface,
      container: container ?? this.container,
      containerHigh: containerHigh ?? this.containerHigh,
      hover: hover ?? this.hover,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceFaint: surfaceFaint ?? this.surfaceFaint,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      surfaceTooltip: surfaceTooltip ?? this.surfaceTooltip,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      glass: glass ?? this.glass,
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
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      destructive: destructive ?? this.destructive,
      statusPlanned: statusPlanned ?? this.statusPlanned,
      statusWatching: statusWatching ?? this.statusWatching,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      statusDropped: statusDropped ?? this.statusDropped,
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
      container: Color.lerp(container, other.container, t)!,
      containerHigh: Color.lerp(containerHigh, other.containerHigh, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceFaint: Color.lerp(surfaceFaint, other.surfaceFaint, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceDisabled: Color.lerp(surfaceDisabled, other.surfaceDisabled, t)!,
      surfaceTooltip: Color.lerp(surfaceTooltip, other.surfaceTooltip, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
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
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      statusPlanned: Color.lerp(statusPlanned, other.statusPlanned, t)!,
      statusWatching: Color.lerp(statusWatching, other.statusWatching, t)!,
      statusCompleted: Color.lerp(statusCompleted, other.statusCompleted, t)!,
      statusDropped: Color.lerp(statusDropped, other.statusDropped, t)!,
      windowCloseHover:
          Color.lerp(windowCloseHover, other.windowCloseHover, t)!,
    );
  }
}

extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}

/// Shared spacing scale. Base unit 4px.
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

/// Shared corner radii.
abstract final class AppRadii {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double pill = 999;
}
