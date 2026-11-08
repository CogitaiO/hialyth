import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/escapable.dart';
import '../../providers/settings_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/repositories_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../widgets/custom_title_bar.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme_extension.dart';
import '../../core/localization/l10n.dart';
import '../../core/logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final tokens = context.appTheme;

    return Escapable(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            CustomTitleBar(
              leading: IconButton(
                icon: Icon(AppIcons.back, color: tokens.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(context.l10n.settingsTitle,
                  style: TextStyle(
                      color: tokens.textPrimary, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final compact = constraints.maxWidth < 900;
                final destinations = [
                  (context.l10n.settingsAppearance, AppIcons.appearance),
                  (context.l10n.settingsPlayback, AppIcons.playback),
                  (context.l10n.settingsLibrary, AppIcons.library),
                  (context.l10n.settingsIntegrations, AppIcons.settings),
                  (context.l10n.settingsAdvanced, AppIcons.advancedSettings),
                ];
                final content = AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: _buildContent(_selectedIndex, accentColor, ref),
                );
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: compact
                          ? Column(children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  for (var i = 0; i < destinations.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        avatar:
                                            Icon(destinations[i].$2, size: 18),
                                        label: Text(destinations[i].$1),
                                        selected: _selectedIndex == i,
                                        onSelected: (_) =>
                                            setState(() => _selectedIndex = i),
                                      ),
                                    ),
                                ]),
                              ),
                              const SizedBox(height: 24),
                              Expanded(child: content),
                            ])
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  SizedBox(
                                      width: 220,
                                      child: Column(children: [
                                        for (var i = 0;
                                            i < destinations.length;
                                            i++)
                                          _MenuTab(
                                            title: destinations[i].$1,
                                            icon: destinations[i].$2,
                                            index: i,
                                            currentIndex: _selectedIndex,
                                            accentColor: accentColor,
                                            onTap: () => setState(
                                                () => _selectedIndex = i),
                                          ),
                                      ])),
                                  const SizedBox(width: 32),
                                  Expanded(child: content),
                                ]),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int index, Color accentColor, WidgetRef ref) {
    switch (index) {
      case 0:
        return _AppearanceSettings(
            key: const ValueKey(0), accentColor: accentColor);
      case 1:
        return _PlayerSettings(
            key: const ValueKey(1), accentColor: accentColor);
      case 2:
        return _LibrarySettings(
            key: const ValueKey(2), accentColor: accentColor);
      case 3:
        return const _IntegrationsSettings(key: ValueKey(3));
      case 4:
        return _AdvancedSettings(
            key: const ValueKey(4), accentColor: accentColor);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _AppearanceSettings extends ConsumerWidget {
  final Color accentColor;
  const _AppearanceSettings({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final tokens = context.appTheme;
    final currentColor = Color(settings.accentColorValue);

    return ListView(children: [
      _SectionHeader(title: context.l10n.settingsAccessibility),
      _SettingsCard(
          child: Column(children: [
        SwitchListTile(
          key: const ValueKey('reduce-transparency'),
          title: Text(context.l10n.settingsReducedTransparency),
          subtitle: Text(context.l10n.settingsReduceTransparencyDescription),
          value: settings.reduceTransparency,
          onChanged: notifier.toggleReduceTransparency,
        ),
        const Divider(height: 1),
        SwitchListTile(
          key: const ValueKey('reduce-motion'),
          title: Text(context.l10n.settingsReducedMotion),
          subtitle: Text(context.l10n.settingsReduceMotionDescription),
          value: settings.reduceMotion,
          onChanged: notifier.toggleReduceMotion,
        ),
      ])),
      const SizedBox(height: AppSpacing.lg),
      _SectionHeader(title: context.l10n.settingsThemeColors),
      _SettingsCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.settingsAppAccentColor,
                  style: TextStyle(color: tokens.textPrimary, fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ...AppPalette.accentPresets.map((c) {
                    final isSelected =
                        settings.accentColorValue == c.toARGB32();
                    return GestureDetector(
                      onTap: () => notifier.updateAccentColor(c),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: tokens.textPrimary, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: c.withValues(alpha: 0.5),
                                      blurRadius: 10)
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? Icon(AppIcons.selected,
                                color: AppPalette.onAccent(c), size: 20)
                            : null,
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () =>
                        _showColorPickerDialog(context, currentColor, notifier),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: AppPalette.accentSpectrum,
                        ),
                        border: Border.all(color: tokens.textMuted, width: 2),
                      ),
                      child: Icon(AppIcons.colorPicker,
                          color: tokens.textPrimary, size: 20),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
    ]);
  }

  void _showColorPickerDialog(
      BuildContext context, Color initialColor, AppSettingsNotifier notifier) {
    Color tempColor = initialColor;
    final tokens = context.appTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardSurface,
        title: Text(context.l10n.settingsCustomColor,
            style: TextStyle(color: tokens.textPrimary)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color;
            },
            colorPickerWidth: 300,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            hexInputBar: true,
            hexInputController: TextEditingController(
                text: '#${initialColor.toHexString().substring(2)}'),
          ),
        ),
        actions: [
          TextButton(
            child: Text(context.l10n.dialogCancel,
                style: TextStyle(color: tokens.textMuted)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: initialColor),
            child: Text(context.l10n.settingsApply,
                style: TextStyle(color: tokens.textPrimary)),
            onPressed: () {
              notifier.updateAccentColor(tempColor);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _IntegrationsSettings extends ConsumerWidget {
  const _IntegrationsSettings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(children: [
        _SectionHeader(title: context.l10n.settingsIntegrations),
        _SettingsCard(
            child: SwitchListTile(
          key: const ValueKey('discord-rpc'),
          title: Text(context.l10n.settingsDiscordRpc),
          subtitle: Text(context.l10n.settingsDiscordRpcDescription),
          value: ref.watch(settingsProvider).discordRpcEnabled,
          onChanged: ref.read(settingsProvider.notifier).toggleDiscordRpc,
        )),
      ]);
}

class _PlayerSettings extends ConsumerWidget {
  final Color accentColor;
  const _PlayerSettings({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final tokens = context.appTheme;

    return ListView(
      children: [
        _SectionHeader(title: context.l10n.settingsPlayback),
        _SettingsCard(
            child: Column(
          children: [
            SwitchListTile(
              activeThumbColor: accentColor,
              title: Text(context.l10n.settingsAutoSkip,
                  style: TextStyle(color: tokens.textPrimary)),
              subtitle: Text(context.l10n.settingsAutoSkipDescription,
                  style: TextStyle(color: tokens.textSubtle)),
              value: settings.autoSkipEnabled,
              onChanged: (val) => notifier.toggleAutoSkip(val),
            ),
          ],
        )),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader(title: context.l10n.settingsLanguagePriority),
        _SettingsCard(
          child: Column(
            children: [
              ListTile(
                title: Text(context.l10n.settingsAudioPriority,
                    style: TextStyle(color: tokens.textPrimary)),
                trailing: DropdownButton<String>(
                  dropdownColor: tokens.cardSurface,
                  value:
                      settings.audioLanguage.startsWith('jpn') ? 'jpn' : 'eng',
                  items: [
                    DropdownMenuItem(
                        value: 'jpn',
                        child: Text(context.l10n.settingsAudioJapaneseOriginal,
                            style: TextStyle(color: tokens.textPrimary))),
                    DropdownMenuItem(
                        value: 'eng',
                        child: Text(context.l10n.settingsAudioEnglishDub,
                            style: TextStyle(color: tokens.textPrimary))),
                  ],
                  onChanged: (val) {
                    if (val == 'jpn') {
                      notifier.updateAudioLang('jpn,jp,eng,en,rus,ru');
                    }
                    if (val == 'eng') {
                      notifier.updateAudioLang('eng,en,jpn,jp,rus,ru');
                    }
                  },
                ),
              ),
              Divider(color: tokens.borderSubtle, height: 1),
              ListTile(
                title: Text(context.l10n.settingsSubtitlePriority,
                    style: TextStyle(color: tokens.textPrimary)),
                trailing: DropdownButton<String>(
                  dropdownColor: tokens.cardSurface,
                  value: settings.subLanguage.startsWith('eng') ? 'eng' : 'rus',
                  items: [
                    DropdownMenuItem(
                        value: 'eng',
                        child: Text(context.l10n.settingsLanguageEnglish,
                            style: TextStyle(color: tokens.textPrimary))),
                    DropdownMenuItem(
                        value: 'rus',
                        child: Text(context.l10n.settingsLanguageRussian,
                            style: TextStyle(color: tokens.textPrimary)))
                  ],
                  onChanged: (val) {
                    if (val == 'eng') notifier.updateSubLang('eng,en,rus,ru');
                    if (val == 'rus') notifier.updateSubLang('rus,ru,eng,en');
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader(title: context.l10n.settingsVideoDecoder),
        _SettingsCard(
          child: ListTile(
            title: Text(context.l10n.settingsHardwareAcceleration,
                style: TextStyle(color: tokens.textPrimary)),
            subtitle: Text(context.l10n.settingsHardwareAccelerationDescription,
                style: TextStyle(color: tokens.textSubtle)),
            trailing: DropdownButton<String>(
              dropdownColor: tokens.cardSurface,
              value: settings.hwdec,
              items: [
                DropdownMenuItem(
                    value: 'auto',
                    child: Text(context.l10n.settingsDecoderAuto,
                        style: TextStyle(color: tokens.textPrimary))),
                DropdownMenuItem(
                    value: 'auto-safe',
                    child: Text(context.l10n.settingsDecoderAutoSafe,
                        style: TextStyle(color: tokens.textPrimary))),
                if (Platform.isWindows)
                  DropdownMenuItem(
                      value: 'd3d11va',
                      child: Text(context.l10n.settingsDecoderWindowsD3d11va,
                          style: TextStyle(color: tokens.textPrimary))),
                DropdownMenuItem(
                    value: 'no',
                    child: Text(context.l10n.settingsDecoderDisabledCpu,
                        style: TextStyle(color: tokens.destructive))),
              ],
              onChanged: (val) {
                if (val != null) notifier.updateHwdec(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  final int currentIndex;
  final Color accentColor;
  final VoidCallback onTap;

  const _MenuTab(
      {required this.title,
      required this.icon,
      required this.index,
      required this.currentIndex,
      required this.accentColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final isSelected = index == currentIndex;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.s14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? accentColor : tokens.textMuted, size: 22),
            const SizedBox(width: AppSpacing.md),
            Text(title,
                style: TextStyle(
                    color: isSelected ? accentColor : tokens.textSecondary,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _LibrarySettings extends ConsumerWidget {
  final Color accentColor;
  const _LibrarySettings({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(savedFoldersProvider);
    final tokens = context.appTheme;
    return ListView(
      children: [
        _SectionHeader(title: context.l10n.settingsFolders),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (folders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                      child: Text(context.l10n.settingsNoFolders,
                          style: TextStyle(color: tokens.textSubtle))),
                )
              else
                ...folders.map(
                  (folder) => ListTile(
                    leading: Icon(AppIcons.folder, color: tokens.textMuted),
                    title: Text(folder,
                        style: TextStyle(color: tokens.textPrimary)),
                    trailing: IconButton(
                      icon: Icon(AppIcons.close, color: tokens.textSubtle),
                      onPressed: () => ref
                          .read(savedFoldersProvider.notifier)
                          .removeFolder(folder),
                      tooltip: context.l10n.settingsRemoveFolder,
                    ),
                  ),
                ),
              Divider(color: tokens.borderSubtle, height: 1),
              InkWell(
                onTap: ref.watch(scanProvider).running
                    ? null
                    : () async {
                        final String? folderPath =
                            await FilePicker.getDirectoryPath();
                        if (folderPath != null) {
                          ref
                              .read(savedFoldersProvider.notifier)
                              .addFolder(folderPath);
                          ref.read(scanProvider.notifier).scan([folderPath]);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(context.l10n.settingsFolderQueued),
                              backgroundColor: tokens.success,
                            ));
                          }
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.add, color: accentColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(context.l10n.settingsAddNewFolder,
                          style: TextStyle(
                              color: accentColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.surfaceHover,
            foregroundColor: tokens.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg)),
          ),
          onPressed: folders.isEmpty || ref.watch(scanProvider).running
              ? null
              : () async {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.settingsScanStarted),
                  ));
                  final result =
                      await ref.read(scanProvider.notifier).scan(folders);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result.errors.isNotEmpty
                          ? context.l10n.libraryScanError
                          : result.warnings > 0
                              ? context.l10n.libraryMetadataWarning
                              : context.l10n.settingsScanCompleted),
                      backgroundColor: tokens.success,
                    ));
                  }
                },
          icon: const Icon(AppIcons.rescan),
          label: Text(context.l10n.settingsRescanLibrary),
        ),
      ],
    );
  }
}

class _AdvancedSettings extends ConsumerWidget {
  final Color accentColor;
  const _AdvancedSettings({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    return ListView(
      children: [
        _SectionHeader(title: context.l10n.settingsDangerZone),
        _SettingsCard(
          child: ListTile(
            iconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
            leading: Icon(AppIcons.delete),
            key: const ValueKey('clear-library-action'),
            title: Text(context.l10n.settingsClearDatabase,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(context.l10n.settingsClearDatabaseDescription,
                style: TextStyle(color: tokens.textSubtle)),
            onTap: ref.watch(scanProvider).running
                ? null
                : () => _confirmClear(context, ref),
          ),
        ),
        const SizedBox(height: 24),
        _SettingsCard(
            child: ListTile(
          leading: const Icon(AppIcons.notes),
          title: Text(context.l10n.settingsViewLogs),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => TalkerScreen(talker: talker))),
        )),
      ],
    );
  }
}

Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
  try {
    final confirmed = await showDialog<bool>(
        context: context, builder: (_) => const _ClearLibraryDialog());
    if (confirmed != true || !context.mounted) return;
    if (ref.read(scanProvider).running) {
      throw StateError('A scan is in progress');
    }
    await ref.read(animeRepoProvider).clearAll();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.commonOperationFailed)));
    }
  }
}

class _ClearLibraryDialog extends StatefulWidget {
  const _ClearLibraryDialog();
  @override
  State<_ClearLibraryDialog> createState() => _ClearLibraryDialogState();
}

class _ClearLibraryDialogState extends State<_ClearLibraryDialog> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.l10n.settingsClearDatabaseConfirmTitle),
        content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(context.l10n.settingsClearDatabaseConfirmBody),
          const SizedBox(height: 16),
          TextField(
              key: const ValueKey('clear-library-confirm'),
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: context.l10n.settingsClearConfirmation),
              onChanged: (_) => setState(() {})),
        ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.dialogCancel)),
          FilledButton(
              key: const ValueKey('clear-library-submit'),
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError),
              onPressed: controller.text == 'DELETE'
                  ? () => Navigator.pop(context, true)
                  : null,
              child: Text(context.l10n.dialogDelete)),
        ],
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xxs),
      child: Text(title,
          style: TextStyle(
              color: tokens.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          clipBehavior: Clip.antiAlias,
          child: child),
    );
  }
}
