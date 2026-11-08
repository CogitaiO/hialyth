import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:nekaido_pre/theme/app_surfaces.dart';
import 'package:nekaido_pre/widgets/glass_surface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Inter')
          ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf')))
        .load();
  });

  testWidgets('glass keeps readable secondary text over white and black frames',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: GlassSurface(
              reduceTransparency: false,
              child: SizedBox(width: 200, height: 100)),
        )));
    final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
    expect(filter.blendMode, BlendMode.src);
    final box = tester.widget<DecoratedBox>(find.descendant(
      of: find.byType(GlassSurface),
      matching: find.byType(DecoratedBox),
    ));
    final fill = (box.decoration as BoxDecoration).color!;
    for (final frame in [Colors.white, Colors.black]) {
      final background = Color.alphaBlend(fill, frame).computeLuminance();
      final text = AppSurfaces.contentSecondary.computeLuminance();
      expect((text + .05) / (background + .05), greaterThanOrEqualTo(4.5));
    }
    expect(AppSurfaces.overlay.a, greaterThanOrEqualTo(.88));
  });

  testWidgets('glass over extreme frames and inside opacity', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(640, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Column(children: [
            for (final frame in [Colors.white, Colors.black])
              Expanded(
                  child: ColoredBox(
                      color: frame,
                      child: Row(children: [
                        for (final opacity in [1.0, .5])
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Opacity(
                                opacity: opacity,
                                child: const GlassSurface(
                                  reduceTransparency: false,
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Player controls',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: AppSurfaces
                                                    .contentPrimary)),
                                        SizedBox(height: 8),
                                        Text('00:42 / 24:00',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: AppSurfaces
                                                    .contentSecondary)),
                                      ]),
                                )),
                          )),
                      ]))),
          ]),
        )));
    await tester.pumpAndSettle();
    await expectLater(find.byType(Scaffold),
        matchesGoldenFile('goldens/player_glass_extreme_frames.png'));
  });

  testWidgets('glass surface blurs its bounded backdrop when enabled',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassSurface(
            reduceTransparency: false,
            child: const SizedBox(width: 120, height: 60),
          ),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('reduced transparency uses the solid fallback without blur',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassSurface(
            reduceTransparency: true,
            child: const SizedBox(width: 120, height: 60),
          ),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
  });
}
