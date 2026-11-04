import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekaido_pre/providers/library_provider.dart';

import '../../../../domain/anime.dart';
import '../../../../providers/repositories_provider.dart';
import '../../../theme/app_theme_extension.dart';

class AnimeDialogs {
  static void openFolderInOs(String? path) {
    if (path == null) return;
    if (Platform.isWindows) {
      Process.run('explorer', [path]);
    } else if (Platform.isMacOS) {
      Process.run('open', [path]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [path]);
    }
  }

  static void showAnimeStatsDialog(
      BuildContext context, Anime anime, Color accentColor) {
    int watchedCount = anime.watchedEpisodes.length;
    double totalHours = (watchedCount * 24) / 60;
    String dateAdded =
        "${anime.dateAdded.day.toString().padLeft(2, '0')}.${anime.dateAdded.month.toString().padLeft(2, '0')}.${anime.dateAdded.year}";

    showDialog(
        context: context,
        builder: (context) {
          final tokens = context.appTheme;
          return AlertDialog(
            backgroundColor: tokens.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            title: Row(
              children: [
                Icon(Icons.bar_chart, color: accentColor),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  "Информация",
                  style: TextStyle(color: tokens.textPrimary),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatRow(context, "Добавлено:", dateAdded),
                const SizedBox(height: AppSpacing.sm),
                _buildStatRow(
                  context,
                  "Просмотрено:",
                  "$watchedCount из ${anime.sortedEpisodes.length}",
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildStatRow(
                  context,
                  "Потрачено:",
                  "~${totalHours.toStringAsFixed(1)} часов",
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildStatRow(
                  context,
                  "Папка:",
                  anime.folderPath ?? "Неизвестно",
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Закрыть", style: TextStyle(color: accentColor)))
            ],
          );
        });
  }

  static void showEditDialog(
      BuildContext context, WidgetRef ref, Anime anime, Color accentColor) {
    TextEditingController titleController =
        TextEditingController(text: anime.title);
    TextEditingController coverController =
        TextEditingController(text: anime.coverUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        final tokens = ctx.appTheme;
        return AlertDialog(
          backgroundColor: tokens.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: accentColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                "Редактировать",
                style: TextStyle(color: tokens.textPrimary),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: tokens.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Название",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                    controller: coverController,
                    style: TextStyle(color: tokens.textPrimary),
                    decoration: InputDecoration(
                      hintText: "URL Постера",
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: accentColor)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.image_search_rounded,
                            color: accentColor),
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.pickFiles(type: FileType.image);
                          if (result != null) {
                            coverController.text = result.files.single.path!;
                          }
                        },
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Отмена",
                style: TextStyle(color: tokens.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              onPressed: () {
                ref.read(animeRepoProvider).editAnimeDetails(
                      anime,
                      titleController.text.trim(),
                      coverController.text.trim(),
                    );
                Navigator.pop(ctx);
              },
              child: Text(
                "Сохранить",
                style: TextStyle(color: tokens.textPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showCollectionDialog(
      BuildContext context, WidgetRef ref, Anime anime, Color accentColor) {
    TextEditingController controller = TextEditingController();

    final allCollections = ref.read(allCollectionsProvider);
    final availableCollections = allCollections
        .where((c) => !anime.customCollections.contains(c))
        .toList();

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final tokens = context.appTheme;
              return AlertDialog(
                backgroundColor: tokens.cardSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                title: Text(
                  "In collections",
                  style: TextStyle(color: tokens.textPrimary),
                ),
                content: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        style: TextStyle(color: tokens.textPrimary),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "New collections",
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: accentColor),
                          ),
                          hintStyle: TextStyle(color: tokens.textSubtle),
                        ),
                      ),
                      if (availableCollections.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          "Or choose from existing ones",
                          style:
                              TextStyle(color: tokens.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: availableCollections.map((colName) {
                            return ActionChip(
                              label: Text(
                                colName,
                                style: TextStyle(color: tokens.textPrimary),
                              ),
                              backgroundColor: tokens.surfaceHover,
                              side: BorderSide.none,
                              onPressed: () {
                                controller.text = colName;
                              },
                            );
                          }).toList(),
                        ),
                      ]
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: tokens.textMuted),
                    ),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: accentColor),
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        if (!anime.customCollections.contains(text)) {
                          anime.customCollections = [
                            ...anime.customCollections,
                            text
                          ];
                          await ref.read(animeRepoProvider).saveAnime(anime);
                        }
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(
                      "Add",
                      style: TextStyle(color: tokens.textPrimary),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  static Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final tokens = context.appTheme;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(color: tokens.textMuted, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
