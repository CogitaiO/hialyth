import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/presentation/debug/design_system_gallery.dart';
import 'package:nekaido_pre/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await (FontLoader('packages/iconsax_flutter/FlutterIconsax')
          ..addFont(rootBundle
              .load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf')))
        .load();
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await inter.load();

    final jetBrainsMono = FontLoader('JetBrainsMono')
      ..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Variable.ttf'));
    await jetBrainsMono.load();
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      (call) async {
        switch (call.method) {
          case 'isMaximized':
          case 'isFullScreen':
          case 'isAlwaysOnTop':
            return false;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
  });

  for (final size in const [
    Size(840, 560),
    Size(1280, 720),
    Size(1920, 1080),
  ]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('design system gallery at $label', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const DesignSystemGallery(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/design_system_gallery_$label.png'),
      );
    });
  }
}
