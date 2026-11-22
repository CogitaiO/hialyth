import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/mobile_navigation_gesture.dart';
import 'package:nekaido_pre/presentation/settings/settings_screen.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> mount(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const windowChannel = MethodChannel('window_manager');
    messenger.setMockMethodCallHandler(windowChannel, (_) async => false);
    addTearDown(() => messenger.setMockMethodCallHandler(windowChannel, null));

    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        libraryProvider.overrideWith((ref) => Stream.value(<Anime>[])),
      ],
    );
    addTearDown(container.dispose);
    final navigation = MobileNavigationController();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark().copyWith(platform: TargetPlatform.android),
          navigatorKey: navigation.key,
          navigatorObservers: [navigation],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(systemGestureInsets: const EdgeInsets.only(right: 24)),
            child: MobileNavigationGesture(
              controller: navigation,
              child: child!,
            ),
          ),
          home: Scaffold(
            body: ListView(
              children: [
                Builder(
                  builder: (context) => TextButton(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(
                          body: Center(child: Text('Title details')),
                        ),
                      ),
                    ),
                    child: const Text('Open title'),
                  ),
                ),
                for (var i = 0; i < 30; i++)
                  ListTile(title: Text('Library item $i')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> swipe(WidgetTester tester, {double y = 260}) async {
    await tester.dragFrom(Offset(342, y), const Offset(-132, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('the edge menu opens from a title and from Settings', (
    tester,
  ) async {
    final container = await mount(tester);
    await tester.tap(find.text('Open title'));
    await tester.pumpAndSettle();
    await swipe(tester);
    expect(find.byType(Drawer), findsOneWidget);
    expect(tester.getRect(find.byType(Drawer)).right, 390);
    expect(find.text('Title details'), findsOneWidget);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await swipe(tester, y: 570);
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.text('Open title'), findsOneWidget);
    expect(container.read(selectedSidebarIndexProvider), 3);
  });

  testWidgets(
    'system edge, middle, short drags and vertical scroll stay free',
    (tester) async {
      await mount(tester);
      await tester.dragFrom(const Offset(384, 260), const Offset(-135, 0));
      await tester.dragFrom(const Offset(230, 260), const Offset(-135, 0));
      await tester.dragFrom(const Offset(342, 260), const Offset(-35, 0));
      await tester.dragFrom(const Offset(310, 260), const Offset(65, 0));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);

      await tester.dragFrom(const Offset(342, 350), const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.pixels, greaterThan(0));

      await swipe(tester);
      expect(find.byType(Drawer), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
    },
  );
}
