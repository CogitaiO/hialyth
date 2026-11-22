import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import 'library_screen.dart';
import 'settings/settings_screen.dart';

class MobileNavigationController extends NavigatorObserver {
  final key = GlobalKey<NavigatorState>();
  Route<dynamic>? _top;

  bool get _canOpen =>
      _top is PageRoute &&
      !_top!.willHandlePopInternally &&
      key.currentState?.userGestureInProgress == false;

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    _top = topRoute;
  }
}

enum _MenuDestination { library, settings }

/// Adds a right-side menu gesture without replacing the routes' own scroll
/// or navigation controls.
class MobileNavigationGesture extends StatefulWidget {
  const MobileNavigationGesture({
    super.key,
    required this.controller,
    required this.child,
  });

  final MobileNavigationController controller;
  final Widget child;

  @override
  State<MobileNavigationGesture> createState() =>
      _MobileNavigationGestureState();
}

class _MobileNavigationGestureState extends State<MobileNavigationGesture> {
  static const _minimumPull = 52.0;
  double _drag = 0;
  bool _showingMenu = false;

  Future<void> _openMenu() async {
    final controller = widget.controller;
    final navigator = controller.key.currentState;
    if (_showingMenu || navigator == null || !controller._canOpen) return;

    _showingMenu = true;
    try {
      final destination = await showGeneralDialog<_MenuDestination>(
        context: navigator.context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        transitionDuration: AppMotion.resolveDuration(
          context,
          AppMotion.medium,
        ),
        transitionBuilder: (context, animation, _, menu) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: AppMotion.enter)).animate(animation),
          child: menu,
        ),
        pageBuilder: (menuContext, _, _) => Align(
          alignment: Alignment.centerRight,
          child: Drawer(
            width: 288,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            child: LibraryNavigation(
              expanded: true,
              onLibrarySelected: () =>
                  Navigator.pop(menuContext, _MenuDestination.library),
              onSettingsSelected: () =>
                  Navigator.pop(menuContext, _MenuDestination.settings),
            ),
          ),
        ),
      );
      if (!mounted || destination == null) return;
      navigator.popUntil((route) => route.isFirst);
      if (destination == _MenuDestination.settings) {
        unawaited(
          navigator.push<void>(
            AppMotion.pageRoute(
              context,
              builder: (_) => const SettingsScreen(),
            ),
          ),
        );
      }
    } finally {
      _showingMenu = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return widget.child;
    }

    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final reservedEdge = MediaQuery.systemGestureInsetsOf(context).right;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Stock Android reserves the outer edge for Back. Start inside that
        // strip (and well away from the home gesture at the bottom).
        final right =
            constraints.maxWidth - (reservedEdge < 8 ? 16 : reservedEdge + 8);
        return RawGestureDetector(
          gestures: {
            _RightEdgeDrag:
                GestureRecognizerFactoryWithHandlers<_RightEdgeDrag>(
                  _RightEdgeDrag.new,
                  (gesture) {
                    gesture.canStart = (position) =>
                        !keyboardOpen &&
                        !_showingMenu &&
                        widget.controller._canOpen &&
                        position.dx >= right - 52 &&
                        position.dx <= right &&
                        position.dy < constraints.maxHeight - 24;
                    gesture.onStart = (_) => _drag = 0;
                    gesture.onUpdate = (details) => _drag += details.delta.dx;
                    gesture.onEnd = (_) {
                      if (_drag <= -_minimumPull) _openMenu();
                    };
                  },
                ),
          },
          child: widget.child,
        );
      },
    );
  }
}

class _RightEdgeDrag extends HorizontalDragGestureRecognizer {
  _RightEdgeDrag() : super(supportedDevices: const {PointerDeviceKind.touch}) {
    dragStartBehavior = DragStartBehavior.down;
  }

  late bool Function(Offset) canStart;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      canStart(event.localPosition) && super.isPointerAllowed(event);
}
