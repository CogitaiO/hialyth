import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_palette.dart';

class AmbientBackground extends StatelessWidget {
  final Color color;
  const AmbientBackground({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -200,
          left: -200,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            width: 800,
            height: 800,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.posterGlow(color),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.posterShadow(color),
                  blurRadius: 200,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
