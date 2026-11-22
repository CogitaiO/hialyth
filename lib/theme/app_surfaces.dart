import 'package:flutter/material.dart';

/// Semantic surface, elevation, and glass tokens.
/// Provides a unified vocabulary for backgrounds, overlays, and glass effects.
/// Includes fallback logic for `reduceTransparency`.
abstract final class AppSurfaces {
  // ── Dark base surfaces ──

  /// Ink backdrop; leaves the brightest values to the artwork and text.
  static const Color base = Color(0xFF15121B);

  /// Navigation chrome, one step above the backdrop.
  static const Color raised = Color(0xFF1D1825);

  /// Recessed/quiet content surfaces, beneath interactive controls.
  static const Color quiet = Color(0xFF211B29);

  /// Fields and control groups.
  static const Color container = Color(0xFF2A2233);

  /// Floating menus and dialogs should remain legible over the content below.
  static const Color containerHigh = Color(0xFF373043);

  /// Hover and active surfaces.
  static const Color hover = Color(0xFF41354D);

  /// Opaque fallback for overlays when glass is disabled — rgba(10,11,13,0.88)
  static const Color overlay = Color(0xE10A0B0D); // 0.88 alpha

  /// Glass surface over video — rgba(20,22,26,0.55)
  static const Color glass = Color(0x8C14161A); // 0.55 alpha

  /// Video background — black
  static const Color videoSurface = Colors.black;

  /// Scrim over video/poster — black 0.35
  static const Color scrim = Color(0x59000000); // 0.35 alpha

  // ── Borders ──

  /// Faint borders — white 0.1
  static const Color borderFaint = Color(0x1AFFFFFF);

  /// Subtle dividers.
  static const Color borderSubtle = Color(0xFF382E44);

  /// Outlines that convey focus or a control boundary.
  static const Color borderStrong = Color(0xFF685B78);

  /// Focus ring — accent color (resolved at runtime)
  static Color borderFocus(Color accent) => accent;

  // ── Content ──

  /// Primary text.
  static const Color contentPrimary = Color(0xFFF7F2FA);

  /// Secondary text.
  static const Color contentSecondary = Color(0xFFCBC1D3);

  /// Metadata and input hints.
  static const Color contentMuted = Color(0xFFA89BB5);

  /// Disabled text — #58606B
  static const Color contentDisabled = Color(0xFF58606B);

  /// Lifts a surface with the artwork's hue without competing with white text.
  static Color artworkWash(
    Color artwork,
    Color surface, {
    double strength = .36,
  }) {
    final hsl = HSLColor.fromColor(artwork);
    final tint = hsl
        .withSaturation(hsl.saturation.clamp(0.0, .62))
        .withLightness(hsl.lightness.clamp(.34, .44))
        .toColor();
    return Color.alphaBlend(tint.withValues(alpha: strength), surface);
  }

  // ── Semantic status colors (not accent) ──

  /// Planned — #C4B5FD
  static const Color statusPlanned = Color(0xFFC4B5FD);

  /// Watching — #7DB7FF
  static const Color statusWatching = Color(0xFF7DB7FF);

  /// Completed — #6EE7B7
  static const Color statusCompleted = Color(0xFF6EE7B7);

  /// Dropped — #FCA5A5
  static const Color statusDropped = Color(0xFFFCA5A5);

  /// Success — #4ADE80
  static const Color success = Color(0xFF4ADE80);

  /// Warning — #FBBF24
  static const Color warning = Color(0xFFFBBF24);

  /// Danger / destructive — #F87171
  static const Color danger = Color(0xFFF87171);

  /// Info — #60A5FA
  static const Color info = Color(0xFF60A5FA);

  // ── Glass configuration ──

  /// Glass border opacity (dark).
  static const double glassBorderOpacity = 0.12;

  /// Glass border opacity (light).
  static const double glassBorderOpacityLight = 0.10;

  /// Maximum simultaneous glass layers on screen.
  static const int maxGlassLayers = 2;

  /// Returns the glass color for the given brightness.
  static Color glassFor(Brightness brightness) =>
      brightness == Brightness.dark ? glass : glass.withValues(alpha: 0.65);

  /// Returns the overlay fallback for the given brightness.
  static Color overlayFor(Brightness brightness) =>
      brightness == Brightness.dark ? overlay : overlay.withValues(alpha: 0.92);

  /// Returns the appropriate surface for a glass container,
  /// respecting `reduceTransparency`.
  static Color resolveGlass({
    required Brightness brightness,
    required bool reduceTransparency,
  }) {
    if (reduceTransparency) return overlayFor(brightness);
    return glassFor(brightness);
  }

  /// Returns the appropriate border for a glass container.
  static Color resolveGlassBorder({
    required Brightness brightness,
    required bool reduceTransparency,
  }) {
    if (reduceTransparency) return borderSubtle;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: glassBorderOpacity)
        : Colors.black.withValues(alpha: glassBorderOpacityLight);
  }
}
