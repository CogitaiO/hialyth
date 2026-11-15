import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/widgets/animated_play_pause_icon.dart';
import 'package:nekaido_pre/theme/app_icons.dart';

void main() {
  testWidgets('play/pause crossfades without morphing or changing layout', (
    tester,
  ) async {
    Widget screen(bool playing, {bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Center(child: AnimatedPlayPauseIcon(playing: playing, size: 52)),
      ),
    );
    await tester.pumpWidget(screen(false));
    final size = tester.getSize(find.byType(AnimatedPlayPauseIcon));
    await tester.pumpWidget(screen(true));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(AppIcons.transportPlay), findsOneWidget);
    expect(find.byIcon(AppIcons.transportPause), findsOneWidget);
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byIcon(AppIcons.transportPause),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, inExclusiveRange(0, 1));
    expect(tester.getSize(find.byType(AnimatedPlayPauseIcon)), size);
    await tester.pumpWidget(screen(false));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pumpWidget(screen(true));
    await tester.pumpAndSettle();
    expect(find.byIcon(AppIcons.transportPause), findsOneWidget);
    expect(find.byIcon(AppIcons.transportPlay), findsNothing);
    await tester.pumpWidget(screen(false, reduced: true));
    expect(find.byIcon(AppIcons.transportPause), findsNothing);
    expect(find.byIcon(AppIcons.transportPlay), findsOneWidget);
  });
}
