import 'package:flutter/material.dart';

/// Application breakpoints and layout constants.
/// Matches the design contract's adaptive layout specification.
abstract final class AppBreakpoints {
  /// Compact: < 900 — no persistent sidebar, top nav/drawer, 1-col cards.
  static const double compact = 900;

  /// Medium starts at 900; expanded layout starts at 1200.
  static const double medium = 1200;

  /// Wide layout starts at 1600.
  static const double expanded = 1600;

  /// Wide: ≥ 1600 — 240px sidebar, constrained content.
  static const double wide = 1600;

  /// Current breakpoint for the given width.
  static Breakpoint forWidth(double width) {
    if (width < compact) return Breakpoint.compact;
    if (width < medium) return Breakpoint.medium;
    if (width < expanded) return Breakpoint.expanded;
    return Breakpoint.wide;
  }

  /// Minimum window width.
  static const double minWindowWidth = 840;

  /// Minimum window height.
  static const double minWindowHeight = 560;

  /// Default window size.
  static const Size defaultWindowSize = Size(1280, 720);

  /// Title bar height.
  static const double titleBarHeight = 40;

  /// Top bar height.
  static const double topBarHeight = 64;

  /// Sidebar widths.
  static const double sidebarCompact = 72; // icon rail
  static const double sidebarExpanded = 220;
  static const double sidebarWide = 240;

  /// Player sidebar width.
  static const double playerSidebarWidth = 360;

  /// Player bottom bar height (without progress).
  static const double playerBottomBarHeight = 72;

  /// Content max widths.
  static const double maxContentLibrary = 1440;
  static const double maxContentDetails = 1200;
  static const double maxContentSettings = 960;
  static const double maxCardWidth = 220;
  static const double minCardWidth = 160;

  /// Grid gap.
  static const double gridGap = 16;

  /// Poster aspect ratio.
  static const double posterAspect = 2 / 3;

  /// Two-column detail threshold.
  static const double detailTwoColumnThreshold = 1000;
}

/// Named breakpoints for semantic use.
enum Breakpoint {
  compact,
  medium,
  expanded,
  wide,
}

/// Extension for responsive values.
extension ResponsiveValue<T> on T {
  T resolveForWidth(
    double width, {
    T? compact,
    T? medium,
    T? expanded,
    T? wide,
  }) {
    final bp = AppBreakpoints.forWidth(width);
    switch (bp) {
      case Breakpoint.compact:
        return compact ?? this;
      case Breakpoint.medium:
        return medium ?? compact ?? this;
      case Breakpoint.expanded:
        return expanded ?? medium ?? compact ?? this;
      case Breakpoint.wide:
        return wide ?? expanded ?? medium ?? compact ?? this;
    }
  }
}
