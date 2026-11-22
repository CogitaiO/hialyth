import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/presentation/anime_details/widgets/sticker_poster.dart';
import 'package:nekaido_pre/theme/app_theme.dart';

const _poster = ValueKey('poster');

Widget _app({bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.dark().copyWith(platform: TargetPlatform.android),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            SizedBox(
              key: _poster,
              width: 160,
              height: 240,
              child: StickerPoster(child: const ColoredBox(color: Colors.teal)),
            ),
            const SizedBox(height: 1000, width: 320),
          ],
        ),
      ),
    ),
  ),
);

Finder get _transform =>
    find.descendant(of: find.byKey(_poster), matching: find.byType(Transform));

ScrollableState _scroll(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable));

void main() {
  for (final cancel in [false, true]) {
    testWidgets(
      'a corner lifts without scrolling, then settles on ${cancel ? 'cancel' : 'release'}',
      (tester) async {
        await tester.pumpWidget(_app());
        final poster = find.byKey(_poster);
        final gesture = await tester.startGesture(
          tester.getTopRight(poster) + const Offset(-12, 12),
        );
        for (var step = 0; step < 9; step++) {
          await gesture.moveBy(const Offset(0, -4));
        }
        await tester.pump();
        final lifted = tester.widget<Transform>(_transform);
        expect(lifted.alignment, Alignment.bottomLeft);
        expect(lifted.transform, isNot(Matrix4.identity()));
        expect(_scroll(tester).position.pixels, 0);

        if (cancel) {
          await gesture.cancel();
        } else {
          await gesture.up();
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final settling = tester.widget<Transform>(_transform).transform;
        expect(settling, isNot(lifted.transform));
        expect(settling, isNot(Matrix4.identity()));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Transform>(_transform).transform,
          Matrix4.identity(),
        );
      },
    );
  }

  testWidgets('a swipe from the middle still scrolls the page', (tester) async {
    await tester.pumpWidget(_app());
    await tester.drag(find.byKey(_poster), const Offset(0, -140));
    await tester.pumpAndSettle();
    expect(_scroll(tester).position.pixels, greaterThan(0));
    expect(tester.widget<Transform>(_transform).transform, Matrix4.identity());
  });

  testWidgets('reduced motion leaves even the corner available for scrolling', (
    tester,
  ) async {
    await tester.pumpWidget(_app(reduceMotion: true));
    await tester.dragFrom(
      tester.getBottomRight(find.byKey(_poster)) - const Offset(12, 12),
      const Offset(0, -140),
    );
    await tester.pumpAndSettle();
    expect(_scroll(tester).position.pixels, greaterThan(0));
    expect(_transform, findsNothing);
  });
}
