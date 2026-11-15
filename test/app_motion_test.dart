import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/theme/app_motion.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:nekaido_pre/widgets/media_card.dart';

void main() {
  testWidgets('reduced motion resolves durations and route timings to zero', (
    tester,
  ) async {
    late Duration duration;
    late PageRoute<void> route;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              duration = AppMotion.resolveDuration(context, AppMotion.slow);
              route = AppMotion.pageRoute<void>(
                context,
                builder: (_) => const SizedBox.shrink(),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(duration, Duration.zero);
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
  });

  testWidgets('normal motion preserves its requested duration', (tester) async {
    late Duration duration;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            duration = AppMotion.resolveDuration(context, AppMotion.slow);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(duration, AppMotion.slow);
  });

  testWidgets('library card hover scale is instantaneous with reduced motion', (
    tester,
  ) async {
    final anime = Anime()..title = 'Test series';
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 220,
                  height: 360,
                  child: AnimeCard(anime: anime),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final card = find.byType(AnimeCard);
    final position = tester.getCenter(card);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: position);
    await mouse.moveTo(position);
    await tester.pump();

    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, 1.015);
    expect(scale.duration, Duration.zero);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
