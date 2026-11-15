import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_motion.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:nekaido_pre/theme/app_theme_extension.dart';
import 'package:nekaido_pre/widgets/play_pause_button.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Finder surface(Finder button) =>
      find.descendant(of: button, matching: find.byType(DecoratedBox));
  BoxDecoration decoration(WidgetTester tester, Finder button) =>
      tester.widget<DecoratedBox>(surface(button)).decoration as BoxDecoration;
  double scale(WidgetTester tester, Finder button) => tester
      .widget<Transform>(
        find.descendant(of: button, matching: find.byType(Transform)).first,
      )
      .transform
      .entry(0, 0);

  testWidgets(
    'touch highlights before playback changes; release and cancellation reset',
    (tester) async {
      var taps = 0;
      const key = ValueKey('play');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Center(
              child: PlayPauseButton(
                key: key,
                playing: false,
                tooltip: 'Play/pause',
                onPressed: () => taps++,
              ),
            ),
          ),
        ),
      );
      final button = find.byKey(key);
      final idle = decoration(tester, button);
      final size = tester.getSize(button);
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump();
      await tester.pump(AppMotion.pressIn);
      expect(taps, 0);
      expect(decoration(tester, button).gradient, isNot(idle.gradient));
      expect(
        decoration(tester, button).boxShadow!.single.color.a,
        greaterThan(idle.boxShadow!.single.color.a),
      );
      expect(decoration(tester, button).border, isNull);
      expect(scale(tester, button), closeTo(.97, .001));
      expect(tester.getSize(button), size);
      await gesture.up();
      expect(taps, 1);
      await tester.pumpAndSettle(const Duration(milliseconds: 120));
      expect(scale(tester, button), 1);
      expect(decoration(tester, button).gradient, idle.gradient);
      final cancelled = await tester.startGesture(tester.getCenter(button));
      await tester.pump(AppMotion.pressIn);
      await cancelled.cancel();
      await tester.pumpAndSettle(const Duration(milliseconds: 120));
      expect(taps, 1);
      expect(scale(tester, button), 1);
    },
  );

  testWidgets(
    'quick taps retain visible feedback without delaying activation',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Center(
              child: PlayPauseButton(
                playing: false,
                tooltip: 'Play/pause',
                onPressed: () => taps++,
              ),
            ),
          ),
        ),
      );
      final button = find.byType(PlayPauseButton);
      await tester.tap(button);
      expect(taps, 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(scale(tester, button), lessThan(.99));
      await tester.pumpAndSettle(const Duration(milliseconds: 120));
      expect(scale(tester, button), 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle(const Duration(milliseconds: 120));
      expect(taps, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reduced motion keeps the surface response but disables scale and fade',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: PlayPauseButton(
                  playing: false,
                  tooltip: 'Play/pause',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );
      final button = find.byType(PlayPauseButton);
      final idle = decoration(tester, button);
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump();
      expect(scale(tester, button), 1);
      expect(decoration(tester, button).gradient, isNot(idle.gradient));
      await gesture.up();
      await tester.pump();
      expect(decoration(tester, button).gradient, idle.gradient);
    },
  );

  testWidgets('transport surface at rest, held, and releasing', (tester) async {
    final previousShadows = debugDisableShadows;
    debugDisableShadows = false;
    try {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(640, 240);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: RepaintBoundary(
                  key: const ValueKey('feedback'),
                  child: ColoredBox(
                    color: context.appTheme.pageSurface,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 24,
                        children: [
                          for (var i = 0; i < 3; i++)
                            PlayPauseButton(
                              key: ValueKey(i),
                              playing: false,
                              tooltip: 'Play/pause',
                              onPressed: () {},
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final held = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey(1))),
      );
      await tester.pump();
      await tester.pump(AppMotion.pressIn);
      await tester.tap(find.byKey(const ValueKey(2)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byKey(const ValueKey('feedback')),
        matchesGoldenFile('goldens/transport_feedback.png'),
      );
      await held.up();
      await tester.pumpAndSettle(const Duration(milliseconds: 120));
    } finally {
      debugDisableShadows = previousShadows;
    }
  });
}
