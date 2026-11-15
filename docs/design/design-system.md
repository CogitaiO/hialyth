# Hialyth design system

This document defines the visual contract for Hialyth's desktop-first Flutter
UI. The Dart tokens in `lib/theme/` are the implementation source of truth;
when this document and the code disagree, update the documentation or tokens
together rather than introducing a second palette or scale.

## Product direction

Hialyth is an anime library and video player, not a music-player clone. Use
Namida as a reference for visual hierarchy, cohesive artwork cards, content
sections, and restrained motion. Keep Hialyth's anime-specific workflows and
desktop navigation. Artwork should lead; controls and metadata should support
it, not compete with it.

## Color roles

- `AppSurfaces` owns the fixed dark foundation: page (`base`), raised chrome
  (`raised`), regular and high containers, hover, overlays, video, borders,
  and content colors.
- `AppPalette` owns the default Iris accent (`#8B7CF6`), user-selectable accent
  presets, status colors, and semantic success/info/warning/danger colors.
- `ColorScheme.primary` is the user action/selection color. Anime status colors
  remain semantic and must not be replaced by the user's accent.
- Poster-derived color is ambient decoration only. Keep it local and subtle;
  do not tint all surfaces or reduce text contrast with it.
- Text roles are primary, secondary, muted, and disabled. Do not use muted or
  disabled text for essential information or interactive labels.
- Prefer opaque surfaces and thin tonal borders to elevation shadows. Glass is
  reserved for controls over video; respect `reduceTransparency` and the
  `AppSurfaces.maxGlassLayers` budget. Never add full-screen blur as ordinary
  page decoration.

## Type

`AppTypography` is the shared type scale: Inter for interface text and
JetBrains Mono for timecodes and technical values. Use named roles instead of
inventing per-widget sizes. Keep title, body, and metadata visibly distinct;
allow text to scale and wrap on compact layouts.

## Layout and shape

- Use `AppSpacing` for common gaps. It is based on a 4 px rhythm; intermediate
  values are intentional exceptions for compact controls and alignment.
- Use `AppRadii` for shared corner shapes. Cards and controls should feel
  related; reserve pill corners for chips and fully rounded controls.
- Use `AppBreakpoints` for window adaptation. Compact layouts must preserve
  usable content and navigation rather than merely shrinking the desktop view.
- Prefer intrinsic content sizing and clear grouping over decorative empty
  panels. Artwork is the primary visual mass on library and details screens.

## Interaction and motion

`AppMotion` owns shared durations and curves. Follow the system/app reduced-
motion preference; decorative movement should disappear when reduced motion is
enabled. State changes must also be conveyed by labels, icons, or shape—not
color alone. Keyboard focus and desktop hover states must remain visible.

## Component and implementation rules

- Use Material `ThemeData` component themes for standard buttons, cards,
  dialogs, chips, inputs, menus, and navigation components.
- Use `AppThemeExtension` for app-specific semantic surface, text, border, and
  status roles. Avoid raw color literals in feature widgets; when a new role is
  genuinely needed, add it to the owning semantic token set and cover it with a
  test.
- Prefer simple fills and borders. Add gradients, shadows, and blur only when
  they communicate hierarchy or support video legibility; account for their
  frame cost on Linux as well as Windows.
- Keep anime-specific labels and statuses clear when artwork or accent colors
  vary.

## Verification contract

- Unit tests protect token values, semantic theme mappings, and responsive
  breakpoints.
- Golden tests capture named screens and states at their intended window sizes.
  Capture the baseline before interacting with controls; interaction/persistence
  assertions belong in separate steps or tests so the golden's state is explicit.
- Goldens verify layout and appearance, not animation smoothness. Validate UI
  and raster frame timings on target Linux and Windows hardware separately.
