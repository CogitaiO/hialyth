import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/services/aniskip_service.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/player/widgets/mobile_player_overlay.dart';
import 'package:nekaido_pre/presentation/player/widgets/player_control_fade.dart';
import 'package:nekaido_pre/presentation/player/widgets/player_overlay.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/providers/player/player_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'player_loading_test.dart' as player_fakes;

class _FadeHarness extends StatefulWidget {
  const _FadeHarness({super.key});

  @override
  State<_FadeHarness> createState() => _FadeHarnessState();
}

class _FadeHarnessState extends State<_FadeHarness> {
  bool visible = true;

  void toggle() => setState(() => visible = !visible);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextButton(
        key: const ValueKey('toggle-fade'),
        onPressed: toggle,
        child: const Text('Toggle'),
      ),
      PlayerControlFade(
        visible: visible,
        duration: const Duration(milliseconds: 300),
        child: TextButton(
          key: const ValueKey('fading-control'),
          onPressed: () {},
          child: const Text('Control'),
        ),
      ),
    ],
  );
}

class _RecordingBackend extends player_fakes.Backend {
  final seeks = <Duration>[];

  @override
  Future<void> seek(Duration value) async => seeks.add(value);
}

Future<PlayerNotifier> _notifier(SharedPreferences prefs) async =>
    PlayerNotifier(
      player_fakes.Repository(),
      prefs,
      engine: player_fakes.Backend(),
      discordService: player_fakes.Presence(),
    );

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'pref_discord': false});
  });

  testWidgets(
    'transparent controls do not hit-test and fade reverses in place',
    (tester) async {
      final harnessKey = GlobalKey<_FadeHarnessState>();
      await tester.pumpWidget(_app(_FadeHarness(key: harnessKey)));
      final control = find.byKey(const ValueKey('fading-control'));

      harnessKey.currentState!.toggle();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final fade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('player-control-fade')),
      );
      final opacityBeforeReverse = fade.opacity.value;

      harnessKey.currentState!.toggle();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final reversedFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('player-control-fade')),
      );
      expect(reversedFade.opacity.value, greaterThan(opacityBeforeReverse));
      expect(tester.getSemantics(control), isNotNull);

      harnessKey.currentState!.toggle();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FadeTransition>(
              find.byKey(const ValueKey('player-control-fade')),
            )
            .opacity
            .value,
        0,
      );
      expect(
        tester
            .widget<IgnorePointer>(
              find
                  .ancestor(of: control, matching: find.byType(IgnorePointer))
                  .first,
            )
            .ignoring,
        isTrue,
      );
      harnessKey.currentState!.toggle();
      await tester.pump();
      expect(
        tester
            .widget<IgnorePointer>(
              find
                  .ancestor(of: control, matching: find.byType(IgnorePointer))
                  .first,
            )
            .ignoring,
        isTrue,
        reason: 'a newly shown control at zero opacity must not hit-test',
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        tester
            .widget<IgnorePointer>(
              find
                  .ancestor(of: control, matching: find.byType(IgnorePointer))
                  .first,
            )
            .ignoring,
        isFalse,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('hidden mobile controls pass taps through to the video', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await _notifier(prefs);
    notifier.toggleUi();
    var videoTaps = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith((ref) => notifier),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: _app(
          Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => videoTaps++,
              ),
              const MobilePlayerOverlay(title: 'Playback'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.byType(Stack).last));
    expect(videoTaps, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('desktop skip control is not tappable while overlay is hidden', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final backend = player_fakes.Backend();
    final notifier = PlayerNotifier(
      player_fakes.Repository(),
      prefs,
      engine: backend,
      discordService: player_fakes.Presence(),
    );
    notifier.state = notifier.state.copyWith(
      playback: notifier.state.playback.copyWith(
        activeSkip: SkipInterval(type: 'op', startTime: 10, endTime: 20),
      ),
      ui: notifier.state.ui.copyWith(isUiVisible: false),
    );
    var videoTaps = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith((ref) => notifier),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: _app(
          Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => videoTaps++,
              ),
              const PlayerOverlay(),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final skip = find.byKey(const ValueKey('desktop-player-skip'));
    expect(skip, findsOneWidget);
    await tester.tap(skip, warnIfMissed: false);
    expect(videoTaps, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('seek restores hidden controls and resets the auto-hide timer', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final backend = _RecordingBackend();
    final notifier = PlayerNotifier(
      player_fakes.Repository(),
      prefs,
      engine: backend,
      discordService: player_fakes.Presence(),
    );
    notifier.state = notifier.state.copyWith(
      playback: notifier.state.playback.copyWith(isPlaying: true),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    notifier.showUi();
    await tester.pump(const Duration(seconds: 2));
    notifier.seek(const Duration(seconds: 42));
    await tester.pump();

    expect(backend.seeks, [const Duration(seconds: 42)]);
    expect(notifier.state.isUiVisible, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(notifier.state.isUiVisible, isTrue);
    await tester.pump(const Duration(milliseconds: 1100));
    expect(notifier.state.isUiVisible, isFalse);
    notifier.beginUiInteraction();
    expect(notifier.state.isUiVisible, isTrue);
    await tester.pump(const Duration(seconds: 4));
    expect(notifier.state.isUiVisible, isTrue);
    notifier.endUiInteraction();
    await tester.pump(const Duration(milliseconds: 2999));
    expect(notifier.state.isUiVisible, isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    expect(notifier.state.isUiVisible, isFalse);
    notifier.dispose();
  });
}
