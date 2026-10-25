import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/escapable.dart';
import '../../providers/settings_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/repositories_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../widgets/custom_title_bar.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';

class SettingsScreen extends ConsumerStatefulWidget{
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(ref.watch(settingsProvider).accentColorValue);
    final tokens = context.appTheme;

    return Escapable(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // Убрали AppBar! Теперь используем Column:
        body: Column(
          children:[
            // НАШ КАСТОМНЫЙ ТАЙТЛ БАР
            CustomTitleBar(
              leading: IconButton(
                icon: Icon(AppIcons.back, color: tokens.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text("Settings", style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
            ),
            
            // ОСНОВНОЙ КОНТЕНТ (обернут в Expanded, чтобы занять остаток экрана)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    SizedBox(
                      width: 250,
                      child: Column(
                        children:[
                          _MenuTab(title: "Appearance", icon: AppIcons.appearance, index: 0, currentIndex: _selectedIndex, accentColor: accentColor, onTap: () => setState(() => _selectedIndex = 0)),
                          _MenuTab(title: "Player", icon: AppIcons.playback, index: 1, currentIndex: _selectedIndex, accentColor: accentColor, onTap: () => setState(() => _selectedIndex = 1)),
                          _MenuTab(title: "Library", icon: AppIcons.library, index: 2, currentIndex: _selectedIndex, accentColor: accentColor, onTap: () => setState(() => _selectedIndex = 2)),
                          _MenuTab(title: "Advanced", icon: AppIcons.advancedSettings, index: 3, currentIndex: _selectedIndex, accentColor: accentColor, onTap: () => setState(() => _selectedIndex = 3)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        ),
                        child: _buildContent(_selectedIndex, accentColor, ref),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int index, Color accentColor, WidgetRef ref) {
    switch (index) {
      case 0: return _AppearanceSettings(key: const ValueKey(0), accentColor: accentColor);
      case 1: return _PlayerSettings(key: const ValueKey(1), accentColor: accentColor);
      case 2: return _LibrarySettings(key: const ValueKey(2), accentColor: accentColor);
      case 3: return _AdvancedSettings(key: const ValueKey(3), accentColor: accentColor);
      default: return const SizedBox.shrink();
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

    final List<Color> presetColors = [
    Color(0xFFF8BBD0), Color(0xFFE1BEE7), Color(0xFFD1C4E9), Color(0xFFC5CAE9),
    Color(0xFFBBDEFB), Color(0xFFB3E5FC), Color(0xFFB2DFDB), Color(0xFFDCEDC8),
    Color(0xFF546E7A), Color(0xFF7E57C2), Color(0xFF26A69A), Color(0xFF66BB6A),
    Color(0xFF9CCC65), Color(0xFFFFB74D), Color(0xFFFFA726), Color(0xFFFF8A65),
    Color(0xFF263238), Color(0xFF303F9F), Color(0xFF880E4F), Color(0xFF1B5E20),
];

    return ListView(children:[
      _SectionHeader(title: "Theme & Colors"),
      _SettingsCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Text("App Accent Color", style: TextStyle(color: tokens.textPrimary, fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children:[
                  ...presetColors.map((c) {
                    final isSelected = settings.accentColorValue == c.toARGB32();
                    return GestureDetector(
                      onTap: () => notifier.updateAccentColor(c),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: tokens.textPrimary, width: 3) : null,
                          boxShadow: isSelected ?[BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 10)] :[],
                        ),
                        child: isSelected ? Icon(AppIcons.selected, color: tokens.textPrimary, size: 20) : null,
                      ),
                    );
                  }),
                  
                  GestureDetector(
                    onTap: () => _showColorPickerDialog(context, currentColor, notifier),
                    
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors:[Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
                        ),
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: Icon(AppIcons.colorPicker, color: tokens.textPrimary, size: 20),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _SectionHeader(title: "Integrations"),
      _SettingsCard(
        child: SwitchListTile(
          activeThumbColor: accentColor,
          title: Text("Discord Rich Presence", style: TextStyle(color: tokens.textPrimary)),
          subtitle: Text("Show the anime you are watching in your Discord status", style: TextStyle(color: tokens.textSubtle)),
          value: settings.discordRpcEnabled,
          onChanged: (val) => notifier.toggleDiscordRpc(val),
        ),
      ),
    ]);
  }

  void _showColorPickerDialog(BuildContext context, Color initialColor, AppSettingsNotifier notifier) {
    Color tempColor = initialColor;
    final tokens = context.appTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardSurface,
        title: Text('Pick Custom Color', style: TextStyle(color: tokens.textPrimary)),
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
            hexInputController: TextEditingController(text: '#${initialColor.toHexString().substring(2)}'),
          ),
        ),
        actions:[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: initialColor),
              child: Text('Apply', style: TextStyle(color: tokens.textPrimary)),
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
        _SectionHeader(title: "Playback"),
        _SettingsCard(
          child: Column(
            children: [
              SwitchListTile(
                activeThumbColor: accentColor,
                title: Text("Auto-skip Openings/Endings", style: TextStyle(color: tokens.textPrimary)),
                subtitle: Text("Automatically skip if AniSkip finds timestamps", style: TextStyle(color: tokens.textSubtle)),
                value: settings.autoSkipEnabled,
                onChanged: (val) => notifier.toggleAutoSkip(val),
              ),
            ],
          )
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader(title: "Languages (Priority)"),
        _SettingsCard(
          child: Column(
            children: [
              ListTile(
                title: Text("Audio Language", style: TextStyle(color: tokens.textPrimary)),
                trailing: DropdownButton<String>(
                  dropdownColor: tokens.cardSurface,
                  value: settings.audioLanguage.startsWith('jpn') ? 'jpn' : 'eng',
                  items: [
                    DropdownMenuItem(value: 'jpn', child: Text("Japanese (Original)", style: TextStyle(color: tokens.textPrimary))),
                    DropdownMenuItem(value: 'eng', child: Text("English (Dub)", style: TextStyle(color: tokens.textPrimary))),
                  ],
                  onChanged: (val) {
                    if (val == 'jpn') notifier.updateAudioLang('jpn,jp,eng,en,rus,ru');
                    if (val == 'eng') notifier.updateAudioLang('eng,en,jpn,jp,rus,ru');
                  },
                ),
              ),
              Divider(color: tokens.borderSubtle, height: 1),
              ListTile(
                title: Text("Subtitle Language", style: TextStyle(color: tokens.textPrimary)),
                trailing: DropdownButton<String>(
                  dropdownColor: tokens.cardSurface,
                  value: settings.subLanguage.startsWith('eng') ? 'eng' : 'rus',
                items: [
                    DropdownMenuItem(value: 'eng', child: Text("English", style: TextStyle(color: tokens.textPrimary))),
                    DropdownMenuItem(value: 'rus', child: Text("Russian", style: TextStyle(color: tokens.textPrimary)))
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
        _SectionHeader(title: "Video Decoder"),
        _SettingsCard(
          child: ListTile(
            title: Text("Hardware Acceleration", style: TextStyle(color: tokens.textPrimary)),
            subtitle: Text("Change this if video is lagging or shows a black screen", style: TextStyle(color: tokens.textSubtle)),
            trailing: DropdownButton<String>(
              dropdownColor: tokens.cardSurface,
              value: settings.hwdec,
              items: [
                DropdownMenuItem(value: 'auto', child: Text("Auto", style: TextStyle(color: tokens.textPrimary))),
                DropdownMenuItem(value: 'auto-safe', child: Text("Auto (Safe)", style: TextStyle(color: tokens.textPrimary))),
                DropdownMenuItem(value: 'd3d11va', child: Text("Windows (d3d11va)", style: TextStyle(color: tokens.textPrimary))),
                DropdownMenuItem(value: 'no', child: Text("Disabled (CPU)", style: TextStyle(color: tokens.destructive))),
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
  
  const _MenuTab({required this.title, required this.icon, required this.index, required this.currentIndex, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context){
    final tokens = context.appTheme;
    final isSelected = index == currentIndex;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? accentColor : tokens.textMuted, size: 22),
            const SizedBox(width: AppSpacing.md),
            Text(title, style: TextStyle(color: isSelected ? accentColor : tokens.textSecondary, fontSize: 16, fontWeight: isSelected ?
                                        FontWeight.bold : FontWeight.w500)),
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
        _SectionHeader(title: "Scanned Folders"),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (folders.isEmpty)
                Padding(
                   padding: const EdgeInsets.all(AppSpacing.lg),
                   child: Center(child: Text("No folders added yet", style: TextStyle(color: tokens.textSubtle))),
                )
              else 
                ...folders.map((folder) => ListTile(
                   leading: Icon(AppIcons.folder, color: tokens.textMuted),
                   title: Text(folder, style: TextStyle(color: tokens.textPrimary)),
                  trailing:  IconButton(
                     icon: Icon(AppIcons.close, color: tokens.textSubtle),
                    onPressed: () => ref.read(savedFoldersProvider.notifier).removeFolder(folder),
                    tooltip: "Remove from library",
                  ),
                ),
              ),
              Divider(color: tokens.borderSubtle, height: 1),
              InkWell(
                onTap: () async {
                  final String? folderPath = await FilePicker.getDirectoryPath();
                  if (folderPath != null) {
                    ref.read(savedFoldersProvider.notifier).addFolder(folderPath);
                    ref.read(scannerProvider).scanAndGroupFiles(folderPath);
                    if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                         content: const Text("Folder added to scan queue"),
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
                      Text("Add New Folder", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
          ),
          onPressed: folders.isEmpty ? null : () async {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Scan started...")));
            final scanner = ref.read(scannerProvider);
            for (var folder in folders) {
              await scanner.scanAndGroupFiles(folder);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Scan completed!"),
                backgroundColor: tokens.success,
              ));
            }
          },
          icon: const Icon(AppIcons.rescan),
          label: const Text("Rescan Library"),
        ),
      ],
    );
  }
}

class _AdvancedSettings extends ConsumerWidget{
  final Color accentColor;
  const _AdvancedSettings({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final tokens = context.appTheme;
    return ListView(
      children: [
        _SectionHeader(title: "Danger Zone"),
         _SettingsCard(
          child: ListTile(
            iconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
            leading: Icon(AppIcons.delete),
            title: const Text("Clear Database", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Removes all titles, watch history, and notes. Media files on disk will NOT be deleted.",
                                  style: TextStyle(color: tokens.textSubtle)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Clear everything?", style: TextStyle(color: tokens.textPrimary)),
                  content: Text("This action cannot be undone.", style: TextStyle(color: tokens.textSecondary)),
                  backgroundColor: tokens.cardSurface,
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel",
                                                                    style: TextStyle(color: tokens.textMuted))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: tokens.destructive),
                      onPressed: () async {
                        await ref.read(animeRepoProvider).clearAll();
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Text("Delete", style: TextStyle(color: tokens.textPrimary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({ required this.title});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xxs),
      child: Text(title, style: TextStyle(color: tokens.textMuted, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
      child: child,
    );
  }
}
