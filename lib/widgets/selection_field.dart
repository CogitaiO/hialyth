import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme_extension.dart';
import '../theme/app_motion.dart';

/// Full-width, anchored selection with no legacy dropdown underline.
class SelectionField<T> extends StatelessWidget {
  const SelectionField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final selected = items.where((item) => item.value == value).firstOrNull;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.containerHigh,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: PopupMenuButton<T>(
          initialValue: value,
          onSelected: onChanged,
          tooltip: '',
          popUpAnimationStyle: AnimationStyle(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppMotion.medium,
            curve: AppMotion.enter,
            reverseCurve: AppMotion.exit,
          ),
          itemBuilder: (_) => [
            for (final item in items)
              PopupMenuItem<T>(
                value: item.value,
                enabled: item.enabled,
                child: Row(
                  children: [
                    Expanded(child: item.child),
                    const SizedBox(width: AppSpacing.sm),
                    Opacity(
                      opacity: item.value == value ? 1 : 0,
                      child: Icon(
                        AppIcons.check,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle.merge(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: selected?.child ?? Text('$value'),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(AppIcons.dropdown, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
