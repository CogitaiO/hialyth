import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:nekaido_pre/presentation/player/widgets/playback_timeline.dart';

void main() {
  testWidgets('small millisecond samples interpolate; seeking and pausing snap',
      (tester) async {
    Widget view(int ms, {bool playing = true, bool reduced = false}) =>
        MaterialApp(
          theme: AppTheme.dark(),
          home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Scaffold(
                  body: PlaybackTimeline(
                      position: Duration(milliseconds: ms),
                      duration: const Duration(seconds: 10),
                      playing: playing,
                      onSeek: (_) {}))),
        );
    double value() => tester.widget<Slider>(find.byType(Slider)).value;
    await tester.pumpWidget(view(0));
    await tester.pumpWidget(view(250));
    await tester.pump(const Duration(milliseconds: 100));
    expect(value(), greaterThan(0));
    expect(value(), lessThan(250));
    await tester.pump(const Duration(milliseconds: 100));
    expect(value(), 250);
    await tester.pumpWidget(view(8000));
    expect(value(), 8000);
    await tester.pumpWidget(view(1000));
    expect(value(), 1000);
    await tester.pumpWidget(view(1250, playing: false));
    expect(value(), 1250);
    await tester.pumpWidget(view(1500, reduced: true));
    expect(value(), 1500);
  });

  testWidgets(
      'seek keeps the requested position until the backend acknowledges it',
      (tester) async {
    Duration? sought;
    Widget view(int ms) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
            body: PlaybackTimeline(
          position: Duration(milliseconds: ms),
          duration: const Duration(seconds: 10),
          playing: true,
          onSeek: (position) => sought = position,
        )));
    await tester.pumpWidget(view(1000));
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChangeStart!(2345.5);
    slider.onChanged!(2345.5);
    slider.onChangeEnd!(2345.5);
    await tester.pump();
    expect(sought, const Duration(milliseconds: 2346));
    expect(tester.widget<Slider>(find.byType(Slider)).value, 2345.5);
    await tester.pumpWidget(view(1100));
    expect(tester.widget<Slider>(find.byType(Slider)).value, 2345.5);
    await tester.pumpWidget(view(2346));
    expect(tester.widget<Slider>(find.byType(Slider)).value, 2346);
    await tester.pumpWidget(const SizedBox());
  });
}
