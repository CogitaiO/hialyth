import 'package:flutter/material.dart';

/// Motion tokens: durations and curves.
/// Respects `reduceMotion` accessibility setting — when enabled, decorative
/// animations become instant (0 ms) or a short fade (80 ms).
abstract final class AppMotion {
  /// 100 ms — color changes, opacity, hover states.
  static const Duration fast = Duration(milliseconds: 100);

  /// 150 ms — buttons, chips, focus rings.
  static const Duration normal = Duration(milliseconds: 150);

  /// 200 ms — overlays, sidebar, menus.
  static const Duration medium = Duration(milliseconds: 200);

  /// 250 ms — page transitions.
  static const Duration page = Duration(milliseconds: 250);

  /// 300 ms — hero transitions, poster expand.
  static const Duration slow = Duration(milliseconds: 300);

  /// 5000 ms — episode autonext countdown.
  static const Duration countdown = Duration(seconds: 5);

  /// Enter curve: easeOutCubic — for things appearing.
  static const Curve enter = Curves.easeOutCubic;

  /// Exit curve: easeInCubic — for things disappearing.
  static const Curve exit = Curves.easeInCubic;

  /// Move curve: easeInOutCubic — for positional changes.
  static const Curve move = Curves.easeInOutCubic;

  /// Emphasized curve: easeOutQuart — for major transitions (hero, page).
  static const Curve emphasized = Curves.easeOutQuart;

  /// Returns the effective duration respecting `reduceMotion`.
  /// Decorative animations (scale, slide, bounce) become 0 ms.
  /// Structural transitions (fade, page) become a short fade.
  static Duration effective(Duration base,
      {bool decorative = false, bool reduceMotion = false}) {
    if (!reduceMotion) return base;
    if (decorative) return Duration.zero;
    return base.inMilliseconds > 150 ? const Duration(milliseconds: 80) : base;
  }

  /// Standard page transition: fade + slide 8px.
  static PageTransitionsBuilder pageTransitionsBuilder(
      {bool reduceMotion = false}) {
    return _AppPageTransitionsBuilder(reduceMotion: reduceMotion);
  }
}

class _AppPageTransitionsBuilder extends PageTransitionsBuilder {
  final bool reduceMotion;
  const _AppPageTransitionsBuilder({required this.reduceMotion});

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion || MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.02),
        end: Offset.zero,
      ).animate(
          CurvedAnimation(parent: animation, curve: AppMotion.emphasized)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
