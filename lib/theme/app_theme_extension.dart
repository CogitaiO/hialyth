import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.titleBarSurface,
    required this.cardSurface,
    required this.surfaceHover,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textSubtle,
    required this.success,
    required this.destructive,
  });

  const AppThemeExtension.dark()
      : titleBarSurface = const Color(0xFF151515),
        cardSurface = const Color(0xFF1A1A1A),
        surfaceHover = const Color(0x1AFFFFFF),
        borderSubtle = Colors.white12,
        textPrimary = Colors.white,
        textSecondary = Colors.white70,
        textMuted = Colors.white54,
        textSubtle = Colors.white38,
        success = Colors.lightGreen,
        destructive = Colors.redAccent;

  final Color titleBarSurface;
  final Color cardSurface;
  final Color surfaceHover;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textSubtle;
  final Color success;
  final Color destructive;

  @override
  AppThemeExtension copyWith({
    Color? titleBarSurface,
    Color? cardSurface,
    Color? surfaceHover,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textSubtle,
    Color? success,
    Color? destructive,
  }) {
    return AppThemeExtension(
      titleBarSurface: titleBarSurface ?? this.titleBarSurface,
      cardSurface: cardSurface ?? this.cardSurface,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textSubtle: textSubtle ?? this.textSubtle,
      success: success ?? this.success,
      destructive: destructive ?? this.destructive,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;

    return AppThemeExtension(
      titleBarSurface: Color.lerp(titleBarSurface, other.titleBarSurface, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      success: Color.lerp(success, other.success, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
    );
  }
}

extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppRadii {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}
