import 'package:flutter/material.dart';
import 'app_motion.dart';
import 'app_palette.dart';
import 'app_surfaces.dart';
import 'app_theme_extension.dart';
import 'app_typography.dart';

/// Centralized Material theme builder. Standard Material components use
/// semantic ColorScheme, AppThemeExtension, and component themes. App-specific
/// widgets should use the same semantic tokens instead of raw color literals.
abstract final class AppTheme {
  /// Builds the dark theme with the given accent color.
  /// [accent] defaults to [AppPalette.fallbackAccent] (Iris).
  static ThemeData dark({Color accent = AppPalette.fallbackAccent}) {
    final scheme = _buildColorScheme(accent, Brightness.dark);
    final extension = AppThemeExtension.dark();

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: extension.pageSurface,
      extensions: [extension],
      textTheme: AppTypography.textTheme(scheme),
      // Font families are baked into TextTheme styles; set here as fallback.
      fontFamily: 'Inter',
      fontFamilyFallback: ['JetBrainsMono', 'Roboto'],

      // ── Component themes ──

      // Buttons
      elevatedButtonTheme: _elevatedButtonTheme(scheme, extension),
      filledButtonTheme: _filledButtonTheme(scheme, extension),
      outlinedButtonTheme: _outlinedButtonTheme(scheme, extension),
      textButtonTheme: _textButtonTheme(scheme, extension),

      // Cards
      cardTheme: _cardTheme(scheme, extension),

      // Dialogs
      dialogTheme: _dialogTheme(scheme, extension),

      // Menus
      menuTheme: _menuTheme(scheme, extension),
      popupMenuTheme: _popupMenuTheme(scheme, extension),

      // Chips
      chipTheme: _chipTheme(scheme, extension),

      // Sliders
      sliderTheme: _sliderTheme(scheme, extension),

      // Tooltips
      tooltipTheme: _tooltipTheme(scheme, extension),

      // Inputs
      inputDecorationTheme: _inputDecorationTheme(scheme, extension),

      // Snackbars
      snackBarTheme: _snackBarTheme(scheme, extension),

      // Tabs
      tabBarTheme: _tabBarTheme(scheme, extension),

      // Dividers
      dividerTheme: _dividerTheme(extension),

      // List tiles
      listTileTheme: _listTileTheme(scheme, extension),

      // Icons
      iconTheme: IconThemeData(
        color: extension.textSecondary,
        size: 20,
      ),

      // App bar (for any legacy MaterialAppBar usage)
      appBarTheme: AppBarTheme(
        backgroundColor: extension.titleBarSurface,
        foregroundColor: extension.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: extension.textPrimary,
        ),
        iconTheme: IconThemeData(color: extension.textPrimary),
        actionsIconTheme: IconThemeData(color: extension.textPrimary),
      ),

      // Bottom sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: extension.container,
        modalBackgroundColor: extension.container,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        ),
        elevation: 0,
      ),

      // Navigation rail (for future medium breakpoint)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: extension.titleBarSurface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme:
            IconThemeData(color: scheme.onPrimaryContainer, size: 24),
        unselectedIconTheme:
            IconThemeData(color: extension.textSubtle, size: 24),
        selectedLabelTextStyle:
            AppTypography.label.copyWith(color: scheme.onPrimaryContainer),
        unselectedLabelTextStyle:
            AppTypography.label.copyWith(color: extension.textSubtle),
        labelType: NavigationRailLabelType.all,
      ),

      // Page transitions
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: AppMotion.pageTransitionsBuilder(),
          TargetPlatform.linux: AppMotion.pageTransitionsBuilder(),
          TargetPlatform.macOS: AppMotion.pageTransitionsBuilder(),
          TargetPlatform.android: AppMotion.pageTransitionsBuilder(),
          TargetPlatform.iOS: AppMotion.pageTransitionsBuilder(),
        },
      ),

      // Visual density — comfortable by default
      visualDensity: VisualDensity.standard,

      // Material tap target size
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // ColorScheme construction
  // ──────────────────────────────────────────────────────────────

  static ColorScheme _buildColorScheme(Color accent, Brightness brightness) {
    final onAccent = AppPalette.onAccent(accent);
    final base =
        brightness == Brightness.dark ? AppSurfaces.base : Colors.white;

    return ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: accent.withValues(alpha: 0.16),
      onPrimaryContainer: brightness == Brightness.dark
          ? AppSurfaces.contentPrimary
          : Colors.black,
      secondary: accent,
      onSecondary: onAccent,
      secondaryContainer: accent.withValues(alpha: 0.12),
      onSecondaryContainer: brightness == Brightness.dark
          ? AppSurfaces.contentPrimary
          : Colors.black,
      surface: base,
      onSurface: brightness == Brightness.dark
          ? AppSurfaces.contentPrimary
          : Colors.black,
      surfaceContainer: AppSurfaces.container,
      surfaceContainerHigh: AppSurfaces.containerHigh,
      surfaceContainerHighest: AppSurfaces.hover,
      onSurfaceVariant: brightness == Brightness.dark
          ? AppSurfaces.contentMuted
          : Colors.grey.shade600,
      outline: AppSurfaces.borderSubtle,
      outlineVariant: AppSurfaces.borderFaint,
      shadow: Colors.black,
      scrim: AppSurfaces.scrim,
      inverseSurface:
          brightness == Brightness.dark ? Colors.white : AppSurfaces.base,
      onInverseSurface: brightness == Brightness.dark
          ? Colors.black
          : AppSurfaces.contentPrimary,
      inversePrimary: accent,
      error: AppPalette.danger,
      onError: AppPalette.onAccent(AppPalette.danger),
      errorContainer: AppPalette.danger.withValues(alpha: 0.16),
      onErrorContainer: AppPalette.danger,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Component theme builders
  // ──────────────────────────────────────────────────────────────

  static ElevatedButtonThemeData _elevatedButtonTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(88, 40)),
        padding:
            WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg))),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return ext.surfaceDisabled;
          if (states.contains(WidgetState.hovered)) {
            return scheme.primary.withValues(alpha: 0.9);
          }
          if (states.contains(WidgetState.focused)) {
            return scheme.primary.withValues(alpha: 0.95);
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.primary.withValues(alpha: 1.0);
          }
          return scheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return ext.textDisabled;
          return scheme.onPrimary;
        }),
        overlayColor:
            WidgetStateProperty.all(scheme.onPrimary.withValues(alpha: 0.12)),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        side: WidgetStateProperty.all(BorderSide.none),
        textStyle: WidgetStateProperty.all(AppTypography.label),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(88, 40)),
        padding:
            WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg))),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return ext.surfaceDisabled;
          if (states.contains(WidgetState.hovered)) {
            return scheme.primary.withValues(alpha: 0.9);
          }
          if (states.contains(WidgetState.focused)) {
            return scheme.primary.withValues(alpha: 0.95);
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.primary.withValues(alpha: 1.0);
          }
          return scheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return ext.textDisabled;
          return scheme.onPrimary;
        }),
        overlayColor:
            WidgetStateProperty.all(scheme.onPrimary.withValues(alpha: 0.12)),
        elevation: WidgetStateProperty.all(0),
        textStyle: WidgetStateProperty.all(AppTypography.label),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(88, 40)),
        padding:
            WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg))),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return ext.textDisabled;
          if (states.contains(WidgetState.hovered)) return scheme.primary;
          if (states.contains(WidgetState.focused)) return scheme.primary;
          return scheme.primary;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return scheme.primaryContainer;
          }
          if (states.contains(WidgetState.focused)) {
            return scheme.primaryContainer;
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.primaryContainer.withValues(alpha: 0.8);
          }
          return Colors.transparent;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: ext.borderSubtle);
          }
          if (states.contains(WidgetState.hovered)) {
            return BorderSide(color: scheme.primary, width: 1.5);
          }
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: scheme.primary, width: 2);
          }
          return BorderSide(color: ext.borderStrong);
        }),
        overlayColor:
            WidgetStateProperty.all(scheme.primary.withValues(alpha: 0.12)),
        textStyle: WidgetStateProperty.all(AppTypography.label),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(64, 36)),
        padding:
            WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg))),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return ext.textDisabled;
          if (states.contains(WidgetState.hovered)) return scheme.primary;
          if (states.contains(WidgetState.focused)) return scheme.primary;
          return scheme.primary;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return scheme.primaryContainer;
          }
          if (states.contains(WidgetState.focused)) {
            return scheme.primaryContainer;
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.primaryContainer.withValues(alpha: 0.8);
          }
          return Colors.transparent;
        }),
        overlayColor:
            WidgetStateProperty.all(scheme.primary.withValues(alpha: 0.12)),
        textStyle: WidgetStateProperty.all(AppTypography.label),
      ),
    );
  }

  static CardThemeData _cardTheme(ColorScheme scheme, AppThemeExtension ext) {
    return CardThemeData(
      color: ext.cardSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    );
  }

  static DialogThemeData _dialogTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return DialogThemeData(
      backgroundColor: ext.container,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xxl)),
      titleTextStyle: AppTypography.titleLarge.copyWith(color: ext.textPrimary),
      contentTextStyle: AppTypography.body.copyWith(color: ext.textSecondary),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      alignment: Alignment.center,
    );
  }

  static MenuThemeData _menuTheme(ColorScheme scheme, AppThemeExtension ext) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(ext.container),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
        shadowColor:
            WidgetStateProperty.all(Colors.black.withValues(alpha: 0.32)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg))),
        padding:
            WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
        maximumSize: WidgetStateProperty.all(const Size(320, double.infinity)),
      ),
    );
  }

  static PopupMenuThemeData _popupMenuTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return PopupMenuThemeData(
      color: ext.container,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.32),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      textStyle: AppTypography.body.copyWith(color: ext.textPrimary),
      // labelTextStyle: WidgetStateProperty.all(AppTypography.label.copyWith(color: scheme.primary)),
      iconColor: ext.textSecondary,
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.basic),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme scheme, AppThemeExtension ext) {
    return ChipThemeData(
      backgroundColor: ext.container,
      disabledColor: ext.surfaceDisabled,
      selectedColor: scheme.primaryContainer,
      secondarySelectedColor: scheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      labelStyle: AppTypography.label.copyWith(color: ext.textPrimary),
      secondaryLabelStyle:
          AppTypography.label.copyWith(color: scheme.onPrimaryContainer),
      brightness: Brightness.dark,
      elevation: 0,
      shadowColor: Colors.transparent,
      pressElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        side: BorderSide(color: ext.borderSubtle),
      ),
      selectedShadowColor: Colors.transparent,
      showCheckmark: false,
    );
  }

  static SliderThemeData _sliderTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: ext.borderSubtle,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.16),
      valueIndicatorColor: scheme.primary,
      valueIndicatorTextStyle:
          AppTypography.monoSmall.copyWith(color: scheme.onPrimary),
      activeTickMarkColor: scheme.primary,
      inactiveTickMarkColor: ext.borderSubtle,
      trackHeight: 2,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 0),
      // rangeTickMarkShape: const RoundRangeTickMarkShape(), // Not available in this Flutter version
      rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
    );
  }

  static TooltipThemeData _tooltipTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: ext.surfaceTooltip,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: ext.borderSubtle),
      ),
      textStyle: AppTypography.caption.copyWith(color: ext.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      verticalOffset: 8,
      preferBelow: true,
      excludeFromSemantics: false,
      waitDuration: const Duration(milliseconds: 300),
      showDuration: const Duration(seconds: 4),
    );
  }

  static InputDecorationThemeData _inputDecorationTheme(
    ColorScheme scheme,
    AppThemeExtension ext,
  ) {
    OutlineInputBorder outline(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationThemeData(
      filled: true,
      fillColor: ext.container,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
      hintStyle: AppTypography.body.copyWith(color: ext.textMuted),
      labelStyle: AppTypography.body.copyWith(color: ext.textSecondary),
      floatingLabelStyle: AppTypography.label.copyWith(color: scheme.primary),
      helperStyle: AppTypography.caption.copyWith(color: ext.textMuted),
      errorStyle: AppTypography.caption.copyWith(color: scheme.error),
      enabledBorder: outline(ext.borderSubtle),
      focusedBorder: outline(scheme.primary, width: 2),
      disabledBorder: outline(ext.borderFaint),
      errorBorder: outline(scheme.error),
      focusedErrorBorder: outline(scheme.error, width: 2),
      prefixIconColor: ext.textMuted,
      suffixIconColor: ext.textMuted,
    );
  }

  static SnackBarThemeData _snackBarTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return SnackBarThemeData(
      backgroundColor: ext.containerHigh,
      contentTextStyle: AppTypography.body.copyWith(color: ext.textPrimary),
      actionTextColor: scheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      elevation: 0,
      showCloseIcon: true,
      closeIconColor: ext.textMuted,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  static TabBarThemeData _tabBarTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: ext.textMuted,
      indicatorColor: scheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: AppTypography.label,
      unselectedLabelStyle: AppTypography.label,
      overlayColor: WidgetStateProperty.all(scheme.primaryContainer),
      splashFactory: NoSplash.splashFactory,
      tabAlignment: TabAlignment.start,
    );
  }

  static DividerThemeData _dividerTheme(AppThemeExtension ext) {
    return DividerThemeData(
      color: ext.borderFaint,
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    );
  }

  static ListTileThemeData _listTileTheme(
      ColorScheme scheme, AppThemeExtension ext) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      tileColor: Colors.transparent,
      selectedTileColor: scheme.primaryContainer,
      selectedColor: scheme.onPrimaryContainer,
      iconColor: ext.textMuted,
      textColor: ext.textPrimary,
      titleTextStyle: AppTypography.title.copyWith(color: ext.textPrimary),
      subtitleTextStyle:
          AppTypography.bodySmall.copyWith(color: ext.textSecondary),
      leadingAndTrailingTextStyle:
          AppTypography.bodySmall.copyWith(color: ext.textMuted),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      horizontalTitleGap: 16,
      minVerticalPadding: 8,
    );
  }
}
