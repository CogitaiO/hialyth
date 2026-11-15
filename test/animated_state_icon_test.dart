import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/widgets/animated_state_icon.dart';

void main() {
  testWidgets('state transition crossfades without changing layout', (
    tester,
  ) async {
    Widget screen(IconData icon, {bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Center(child: AnimatedStateIcon(icon, size: 32)),
      ),
    );
    await tester.pumpWidget(screen(Icons.play_arrow));
    final size = tester.getSize(find.byType(AnimatedStateIcon));
    await tester.pumpWidget(screen(Icons.pause));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(tester.getSize(find.byType(AnimatedStateIcon)), size);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_arrow), findsNothing);
    await tester.pumpWidget(screen(Icons.play_arrow, reduced: true));
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsNothing);
  });
}
