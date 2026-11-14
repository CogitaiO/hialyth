import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/presentation/debug/showcase_console_screen.dart';
import 'package:nekaido_pre/providers/repositories_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';

class _ShowcaseRepository extends Fake implements AnimeRepository {
  final anime = <Anime>[];

  @override
  Stream<List<Anime>> watchLibrary() => Stream.value(anime);

  @override
  Future<void> saveAnime(Anime item) async {
    anime.add(item);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ShowcaseRepository repository;
  const windowManager = MethodChannel('window_manager');

  setUp(() {
    repository = _ShowcaseRepository();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManager, (call) async => false);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManager, null);
  });

  testWidgets('console creates a custom fixture with a bundled poster',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [animeRepoProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const ShowcaseConsoleScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).at(0), 'Demo feature title');
    await tester.enterText(find.byType(TextField).at(1), '8');
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.tap(find.text('Add to demo library'));
    await tester.pumpAndSettle();

    expect(repository.anime, hasLength(1));
    expect(repository.anime.single.title, 'Demo feature title');
    expect(repository.anime.single.episodePaths, hasLength(8));
    expect(repository.anime.single.watchedEpisodes, hasLength(2));
    expect(repository.anime.single.coverUrl,
        'asset:assets/showcase/posters/violet.png');
    expect(tester.takeException(), isNull);
  });
}
