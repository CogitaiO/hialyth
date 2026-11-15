import 'package:flutter/material.dart';

/// Motion tokens: durations and curves.
/// Respects the `disableAnimations` accessibility setting — all visual
/// transitions become instantaneous while their state changes still run.
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

  /// Transport press feedback is independent from the playback icon fade.
  static const Duration pressIn = Duration(milliseconds: 100);
  static const Duration pressHold = Duration(milliseconds: 100);
  static const Duration pressOut = Duration(milliseconds: 320);

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

  /// Whether this subtree should render visual transitions instantaneously.
  static bool isReduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Resolves a motion token against the system/accessibility preference.
  static Duration resolveDuration(BuildContext context, Duration duration) =>
      isReduced(context) ? Duration.zero : duration;

  /// Context-free counterpart for callers that already hold the preference.
  /// [decorative] is retained for source compatibility; reduced motion now
  /// makes every visual transition instantaneous, not only decorative ones.
  static Duration effective(
    Duration base, {
    bool decorative = false,
    bool reduceMotion = false,
  }) {
    return reduceMotion ? Duration.zero : base;
  }

  /// Material route with platform behavior and reduced-motion timing resolved
  /// when it is pushed, for consistent forward and reverse transitions.
  static PageRoute<T> pageRoute<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) => _AppMaterialPageRoute<T>(
    builder: builder,
    reduceMotion: isReduced(context),
  );

  /// Standard page transition: fade + slide 8px.
  static PageTransitionsBuilder pageTransitionsBuilder({
    bool reduceMotion = false,
  }) {
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
    if (reduceMotion || AppMotion.isReduced(context)) return child;
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: animation, curve: AppMotion.emphasized),
          ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class _AppMaterialPageRoute<T> extends MaterialPageRoute<T> {
  _AppMaterialPageRoute({required super.builder, required this.reduceMotion});

  final bool reduceMotion;

  @override
  Duration get transitionDuration =>
      reduceMotion ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : super.reverseTransitionDuration;
}
