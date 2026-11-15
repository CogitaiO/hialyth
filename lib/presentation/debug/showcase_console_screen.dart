import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo/showcase_fixtures.dart';
import '../../domain/anime.dart';
import '../../providers/library_provider.dart';
import '../../providers/repositories_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/anime_artwork.dart';
import '../../widgets/custom_title_bar.dart';

class ShowcaseConsoleScreen extends ConsumerStatefulWidget {
  const ShowcaseConsoleScreen({super.key});

  @override
  ConsumerState<ShowcaseConsoleScreen> createState() =>
      _ShowcaseConsoleScreenState();
}

class _ShowcaseConsoleScreenState extends ConsumerState<ShowcaseConsoleScreen> {
  final _titleController = TextEditingController();
  final _episodeController = TextEditingController(text: '12');
  final _watchedController = TextEditingController(text: '3');
  AnimeStatus _status = AnimeStatus.watching;
  String? _cover = 'asset:${ShowcaseFixtures.posterAssets.first}';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _episodeController.dispose();
    _watchedController.dispose();
    super.dispose();
  }

  Future<void> _addPresetSet() async {
    final added =
        await ShowcaseFixtures.addPresetSet(ref.read(animeRepoProvider));
    if (!mounted) return;
    _message(added == 0
        ? 'All preset titles are already in the Showcase library.'
        : 'Added $added sample anime.');
  }

  Future<void> _addCustomAnime() async {
    final title = _titleController.text.trim();
    final episodes = int.tryParse(_episodeController.text.trim());
    final watched = int.tryParse(_watchedController.text.trim());
    if (title.isEmpty || episodes == null || watched == null) {
      _message('Enter a title and valid episode counts.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(animeRepoProvider).saveAnime(
            ShowcaseFixtures.customAnime(
              title: title,
              episodes: episodes,
              watched: watched,
              status: _status,
              cover: _cover,
            ),
          );
      _titleController.clear();
      if (mounted) _message('Added "$title" to the Showcase library.');
    } catch (error) {
      if (mounted) _message('Could not add anime: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _chooseLocalCover() async {
    final result = await FilePicker.pickFile(type: FileType.image);
    if (result?.path == null || !mounted) return;
    setState(() => _cover = result!.path);
  }

  Future<void> _clearShowcaseLibrary() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Showcase library?'),
        content: const Text(
            'This removes the sample records from the isolated Showcase database. Your regular library is not used by this build.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear demo data')),
        ],
      ),
    );
    if (clear != true || !mounted) return;
    await ref.read(animeRepoProvider).clearAll();
    if (mounted) _message('Showcase library cleared.');
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider).valueOrNull ?? const <Anime>[];
    final tokens = context.appTheme;

    return Scaffold(
      body: Column(children: [
        CustomTitleBar(
          leading: IconButton(
            tooltip: 'Back to library',
            icon: const Icon(AppIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Showcase developer console',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(children: [
                        Icon(AppIcons.shield, color: tokens.info),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Text(
                              'Isolated demo data — this console cannot access your regular library.'),
                        ),
                        Text('${library.length} items',
                            style: Theme.of(context).textTheme.labelLarge),
                      ]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Quick actions',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.icon(
                          onPressed: _addPresetSet,
                          icon: const Icon(AppIcons.add),
                          label: const Text('Add sample set'),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              library.isEmpty ? null : _clearShowcaseLibrary,
                          icon: const Icon(AppIcons.delete),
                          label: const Text('Clear demo library'),
                        ),
                      ]),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Add fictitious anime',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                  labelText: 'Anime title',
                                  hintText: 'A title for layout testing'),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            LayoutBuilder(builder: (context, constraints) {
                              final compact = constraints.maxWidth < 600;
                              final fields = [
                                _numberField(
                                    _episodeController, 'Total episodes'),
                                _numberField(_watchedController, 'Watched'),
                                DropdownButtonFormField<AnimeStatus>(
                                  initialValue: _status,
                                  decoration: const InputDecoration(
                                      labelText: 'Status'),
                                  items: [
                                    for (final status in AnimeStatus.values)
                                      DropdownMenuItem(
                                          value: status,
                                          child: Text(_statusName(status))),
                                  ],
                                  onChanged: (value) => setState(
                                      () => _status = value ?? _status),
                                ),
                              ];
                              return compact
                                  ? Column(children: [
                                      for (final field in fields) ...[
                                        field,
                                        const SizedBox(height: AppSpacing.sm),
                                      ],
                                    ])
                                  : Row(children: [
                                      for (var i = 0;
                                          i < fields.length;
                                          i++) ...[
                                        if (i > 0)
                                          const SizedBox(width: AppSpacing.sm),
                                        Expanded(child: fields[i]),
                                      ],
                                    ]);
                            }),
                            Row(children: [
                              SizedBox(
                                width: 42,
                                height: 60,
                                child: _cover == null
                                    ? const Icon(AppIcons.image)
                                    : _cover!.startsWith('asset:')
                                        ? AnimeArtwork(cover: _cover, radius: 6)
                                        : Image.file(File(_cover!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const Icon(
                                                    AppIcons.imageMissing)),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  key: ValueKey(_cover),
                                  initialValue: _cover,
                                  decoration: const InputDecoration(
                                      labelText: 'Poster'),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                        value: null, child: Text('No poster')),
                                    if (_cover != null &&
                                        !_cover!.startsWith('asset:'))
                                      DropdownMenuItem<String?>(
                                          value: _cover,
                                          child: const Text('Local image')),
                                    for (final asset
                                        in ShowcaseFixtures.posterAssets)
                                      DropdownMenuItem<String?>(
                                          value: 'asset:$asset',
                                          child: Text(_posterName(asset))),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _cover = value),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Choose a local image',
                                onPressed: _chooseLocalCover,
                                icon: const Icon(AppIcons.folderOpen),
                              ),
                            ]),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: _saving ? null : _addCustomAnime,
                                icon: const Icon(AppIcons.add),
                                label: const Text('Add to demo library'),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Current demo titles',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  for (final anime in library)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      leading: SizedBox(
                        width: 36,
                        height: 52,
                        child: AnimeArtwork(
                            cover: anime.coverUrl, radius: AppRadii.sm),
                      ),
                      title: Text(anime.title),
                      subtitle: Text(
                          '${_statusName(anime.status)} · ${anime.progressFraction}'),
                      trailing: IconButton(
                        tooltip: 'Remove demo title',
                        icon: const Icon(AppIcons.delete),
                        onPressed: () =>
                            ref.read(animeRepoProvider).deleteAnime(anime.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _numberField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      );

  String _statusName(AnimeStatus status) => switch (status) {
        AnimeStatus.planned => 'Planned',
        AnimeStatus.watching => 'Watching',
        AnimeStatus.completed => 'Completed',
        AnimeStatus.dropped => 'Dropped',
      };

  String _posterName(String path) =>
      path.split('/').last.replaceAll('.png', '').replaceAll('_', ' ');
}
