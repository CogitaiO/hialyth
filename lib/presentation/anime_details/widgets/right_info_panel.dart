import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/anime.dart';
import '../../player/player_screen.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';

class RightInfoPanel extends StatelessWidget {
  final Anime anime;
  final Color accentColor;

  const RightInfoPanel({
    super.key,
    required this.anime,
    required this.accentColor,
  });

  void _playEpisode(BuildContext context, String path) {
    if (!File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Файл не найден!"),
          backgroundColor: context.appTheme.destructive,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PlayerScreen(animeId: anime.id, videoPath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedEpisodes = anime.sortedEpisodes;
    final fileExtension = sortedEpisodes.isNotEmpty
        ? sortedEpisodes.first.split('.').last.toUpperCase()
        : "UNKNOWN";
    final tokens = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === ЗАГОЛОВОК ===
        Text(
          anime.title,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: tokens.textPrimary,
            letterSpacing: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),

        // === БЕЙДЖИ ===
        Row(
          children: [
            _buildInfoChip(context, AppIcons.videoLibrary,
                "Серий: ${sortedEpisodes.length}"),
            const SizedBox(width: AppSpacing.sm),
            _buildInfoChip(context, AppIcons.fileFormat, fileExtension),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildInfoChip(
                context,
                AppIcons.folder,
                anime.folderPath?.split(Platform.pathSeparator).last ??
                    "Неизвестно",
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // === ОПИСАНИЕ ===
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: tokens.scrim(0.2),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: tokens.surfaceSubtle),
          ),
          child: Text(
            anime.descripion ??
                "Описание пока отсутствует. Обновите данные из сети.",
            style: TextStyle(
              color: anime.descripion == null
                  ? tokens.textSubtle
                  : tokens.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // === СПИСОК ЭПИЗОДОВ ===
        Text(
          "Список эпизодов",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: tokens.surfaceFaint,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: tokens.surfaceSubtle),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: sortedEpisodes.length,
                separatorBuilder: (context, index) => Divider(
                  color: tokens.borderSubtle,
                  height: 1,
                  indent: AppSpacing.s20,
                  endIndent: AppSpacing.s20,
                ),
                itemBuilder: (context, index) {
                  final episodePath = sortedEpisodes[index];
                  final isWatched = anime.watchedEpisodes.contains(episodePath);

                  return _EpisodeTile(
                    index: index + 1,
                    isWatched: isWatched,
                    accentColor: accentColor,
                    onTap: () => _playEpisode(context, episodePath),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    final tokens = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.textSecondary),
          const SizedBox(width: AppSpacing.s6),
          Text(
            text,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeTile extends StatefulWidget {
  final int index;
  final bool isWatched;
  final Color accentColor;
  final VoidCallback onTap;

  const _EpisodeTile(
      {required this.index,
      required this.isWatched,
      required this.accentColor,
      required this.onTap});

  @override
  State<_EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<_EpisodeTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isHovered ? tokens.surfaceSubtle : Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppSpacing.s40,
                child: Text(
                  "${widget.index}",
                  style: TextStyle(
                    color: widget.isWatched
                        ? tokens.textSubtle
                        : (isHovered
                            ? tokens.textPrimary
                            : tokens.textSecondary),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Эпизод ${widget.index}",
                      style: TextStyle(
                        color: widget.isWatched
                            ? tokens.textSubtle
                            : tokens.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                scale: isHovered ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.isWatched
                      ? AppIcons.checkCircle
                      : (isHovered
                          ? AppIcons.playCircle
                          : AppIcons.playCircleOutline),
                  color: widget.isWatched
                      ? tokens.success
                      : (isHovered ? widget.accentColor : tokens.textMuted),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
