import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme_extension.dart';

class CustomTitleBar extends StatefulWidget {
  final Color? backgroundColor;
  final Widget? leading; // Optional leading widget, e.g. a back button.
  final Widget? title; // Optional title widget.

  const CustomTitleBar({
    super.key,
    this.backgroundColor,
    this.leading,
    this.title,
  });

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;
  bool _isFullScreen = false;
  bool _isPiP = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _updateState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _updateState() async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;

    final isMaximized = await windowManager.isMaximized();
    final isFullScreen = await windowManager.isFullScreen();
    final isPiP = await windowManager.isAlwaysOnTop();

    if (mounted) {
      setState(() {
        _isMaximized = isMaximized;
        _isFullScreen = isFullScreen;
        _isPiP = isPiP;
      });
    }
  }

  @override
  void onWindowMaximize() => _updateState();
  @override
  void onWindowUnmaximize() => _updateState();
  @override
  void onWindowEnterFullScreen() => _updateState();
  @override
  void onWindowLeaveFullScreen() => _updateState();

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return const SizedBox.shrink();
    }
    // The title bar is hidden in PiP.
    if (_isPiP) return const SizedBox.shrink();
    final tokens = context.appTheme;

    return Container(
      height: AppSpacing.s40, // Taller drag target.
      color: widget.backgroundColor ?? tokens.titleBarSurface,
      child: Row(
        children: [
          if (widget.leading != null)
            widget.leading!
          else ...[
            const SizedBox(width: AppSpacing.md),
            Icon(AppIcons.appLogo,
                color: Theme.of(context).colorScheme.primary, size: 18),
            const SizedBox(width: AppSpacing.xs),
          ],

          if (widget.title != null)
            widget.title!
          else
            Text(
              'Nekaido',
              style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),

          // Leave the drag area empty in fullscreen.
          Expanded(
            child: _isFullScreen
                ? const SizedBox.shrink()
                : DragToMoveArea(
                    child: Container(color: Colors.transparent),
                  ),
          ),

          // Window controls are hidden in fullscreen.
          if (!_isFullScreen && (Platform.isWindows || Platform.isLinux)) ...[
            _WindowButton(
              icon: AppIcons.minimize,
              onTap: () async => await windowManager.minimize(),
            ),
            _WindowButton(
              icon: _isMaximized ? AppIcons.restore : AppIcons.maximize,
              iconSize: _isMaximized ? 12 : 14,
              onTap: () async {
                if (_isMaximized) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            _WindowButton(
              icon: AppIcons.close,
              hoverColor: tokens.windowCloseHover,
              onTap: () async => await windowManager.close(),
            ),
          ],
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? hoverColor;
  final double iconSize;

  const _WindowButton({
    required this.icon,
    required this.onTap,
    this.hoverColor,
    this.iconSize = 16,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final hoverColor = widget.hoverColor ?? tokens.borderStrong;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 46,
          height: double.infinity,
          color: _isHovered ? hoverColor : Colors.transparent,
          child: Icon(
            widget.icon,
            color: _isHovered && widget.hoverColor != null
                ? tokens.textPrimary
                : tokens.textSecondary,
            size: widget.iconSize,
          ),
        ),
      ),
    );
  }
}
