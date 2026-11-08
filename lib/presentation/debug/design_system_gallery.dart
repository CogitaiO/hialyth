import 'package:flutter/material.dart';

import '../../theme/app_breakpoints.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_surfaces.dart';
import '../../theme/app_theme_extension.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_title_bar.dart';

class DesignSystemGallery extends StatelessWidget {
  const DesignSystemGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          const CustomTitleBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text('Design System Gallery', style: AppTypography.display),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Debug-only preview of Hialyth foundation tokens and components.',
                  style: AppTypography.body.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: AppSpacing.xl),
                _GallerySection(
                  title: 'Surfaces and semantic colors',
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _Swatch(label: 'Base', color: AppSurfaces.base),
                      _Swatch(label: 'Raised', color: AppSurfaces.raised),
                      _Swatch(label: 'Container', color: AppSurfaces.container),
                      _Swatch(
                          label: 'Container high',
                          color: AppSurfaces.containerHigh),
                      _Swatch(label: 'Hover', color: AppSurfaces.hover),
                      _Swatch(label: 'Accent', color: scheme.primary),
                      _Swatch(label: 'Success', color: AppPalette.success),
                      _Swatch(label: 'Warning', color: AppPalette.warning),
                      _Swatch(label: 'Danger', color: AppPalette.danger),
                    ],
                  ),
                ),
                _GallerySection(
                  title: 'Typography',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Display heading', style: AppTypography.display),
                      Text('Section headline', style: AppTypography.headline),
                      Text('Title and card heading',
                          style: AppTypography.title),
                      Text('Body text for descriptions and messages.',
                          style: AppTypography.body),
                      Text('Small secondary text',
                          style: AppTypography.bodySmall),
                      Text('00:42:18  ·  1920×1080', style: AppTypography.mono),
                    ],
                  ),
                ),
                _GallerySection(
                  title: 'Buttons and input',
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Primary')),
                      FilledButton(
                          onPressed: () {}, child: const Text('Filled')),
                      OutlinedButton(
                          onPressed: () {}, child: const Text('Outlined')),
                      TextButton(
                          onPressed: () {}, child: const Text('Text button')),
                      const SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Search library',
                            hintText: 'Title or filename',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 300,
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Disabled input',
                            hintText: 'Unavailable',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _GallerySection(
                  title: 'Cards, chips, slider, and dialog',
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sample title',
                                    style: AppTypography.title),
                                const SizedBox(height: AppSpacing.xs),
                                Text('Card surface with secondary copy.',
                                    style: AppTypography.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Chip(label: Text('Default chip')),
                      FilterChip(
                        label: const Text('Selected chip'),
                        selected: true,
                        color: WidgetStatePropertyAll(scheme.primaryContainer),
                        onSelected: (_) {},
                      ),
                      SizedBox(
                        width: 240,
                        child: Slider(value: 0.58, onChanged: (_) {}),
                      ),
                      ElevatedButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Dialog title'),
                            content: const Text(
                                'This preview uses the shared dialog theme.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                        child: const Text('Show dialog'),
                      ),
                    ],
                  ),
                ),
                _GallerySection(
                  title: 'Layout and motion tokens',
                  child: Text(
                    'Breakpoints: compact < ${AppBreakpoints.compact.toInt()} · '
                    'medium < ${AppBreakpoints.medium.toInt()} · '
                    'expanded < ${AppBreakpoints.expanded.toInt()} · '
                    'wide ≥ ${AppBreakpoints.wide.toInt()} px\n'
                    'Motion: ${AppMotion.fast.inMilliseconds} / '
                    '${AppMotion.normal.inMilliseconds} / '
                    '${AppMotion.page.inMilliseconds} / '
                    '${AppMotion.slow.inMilliseconds} ms',
                    style: AppTypography.monoSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  final String title;
  final Widget child;

  const _GallerySection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.titleLarge
                      .copyWith(color: tokens.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String label;
  final Color color;

  const _Swatch({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return SizedBox(
      width: 124,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: tokens.borderSubtle),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.caption),
          Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: AppTypography.monoSmall.copyWith(color: tokens.textMuted)),
        ],
      ),
    );
  }
}
