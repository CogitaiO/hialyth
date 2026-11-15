import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/anime_details/anime_details_screen.dart';
import 'package:nekaido_pre/presentation/anime_details/dialogs/anime_dialogs.dart';
import 'package:nekaido_pre/presentation/anime_details/dialogs/collection_dialog.dart';
import 'package:nekaido_pre/presentation/anime_details/widgets/right_info_panel.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/providers/repositories_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';

class _Repository extends Fake implements AnimeRepository {
  final saved = <String>[];
  Completer<void>? pending;
  bool fail = false;

  @override
  Future<void> addToCollection(int id, String name) async {
    saved.add(name);
    if (fail) throw StateError('Save failed');
    await pending?.future;
  }
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (call) async => false,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
  });

  Future<void> mount(
    WidgetTester tester,
    _Repository repository, {
    List<String> collections = const [],
    bool details = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final anime = Anime()
      ..id = 1
      ..title = 'Example';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          animeRepoProvider.overrideWithValue(repository),
          allCollectionsProvider.overrideWithValue(collections),
          animeDetailsProvider(1).overrideWith((ref) => Stream.value(anime)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: details
              ? const AnimeDetailsScreen(animeId: 1, heroTag: 'test')
              : Scaffold(
                  body: Consumer(
                    builder: (context, ref, _) => TextButton(
                      onPressed: () => AnimeDialogs.showCollectionDialog(
                        context,
                        ref,
                        anime,
                        Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final field = find.byKey(const ValueKey('collection-name'));
  final save = find.byKey(const ValueKey('collection-save'));

  testWidgets('keyboard focus waits until the dialog entrance completes', (
    tester,
  ) async {
    await mount(tester, _Repository());
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isFalse);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large collection lists are lazy and fit above the keyboard', (
    tester,
  ) async {
    final repository = _Repository();
    await mount(
      tester,
      repository,
      collections: List.generate(1000, (i) => 'Collection $i'),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile).evaluate().length, lessThan(20));
    expect(find.text('Collection 999'), findsNothing);
    await tester.tap(find.text('Collection 0'));
    expect(tester.widget<TextField>(field).controller!.text, 'Collection 0');
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.saved, ['Collection 0']);
  });

  testWidgets('save trims the name and prevents overlapping submissions', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer<void>();
    await mount(tester, repository);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(save).onPressed, isNull);
    await tester.enterText(field, '  Favourites  ');
    await tester.pump();
    final submit = tester.widget<ElevatedButton>(save).onPressed!;
    submit();
    submit();
    await tester.pump();
    expect(repository.saved, ['Favourites']);
    expect(tester.widget<ElevatedButton>(save).onPressed, isNull);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CollectionDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed saves retain the name and allow retry', (tester) async {
    final repository = _Repository()..fail = true;
    await mount(tester, repository);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(field, 'Favourites');
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).decoration!.errorText, isNotNull);
    expect(tester.widget<TextField>(field).controller!.text, 'Favourites');
    repository.fail = false;
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.saved, ['Favourites', 'Favourites']);
    expect(find.byType(CollectionDialog), findsNothing);
  });

  testWidgets('keyboard insets do not relayout the details behind the dialog', (
    tester,
  ) async {
    await mount(tester, _Repository(), details: true);
    final before = tester.getSize(find.byType(RightInfoPanel));
    await tester.tap(find.byTooltip('Collection'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(RightInfoPanel)), before);
    expect(tester.takeException(), isNull);
  });
}
