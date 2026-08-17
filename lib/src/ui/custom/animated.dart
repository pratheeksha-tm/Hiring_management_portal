import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/utils/colors.dart';

class AnimatedBrandText extends StatefulWidget {
  const AnimatedBrandText({super.key});

  @override
  State<AnimatedBrandText> createState() => _AnimatedBrandTextState();
}

class _AnimatedBrandTextState extends State<AnimatedBrandText> {
  final String text = "ARTISAN";

  int activeIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;

      setState(() {
        activeIndex = (activeIndex + 1) % text.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(text.length, (index) {
        final active = index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, active ? -8.0 : 0.0)
            ..scale(active ? 1.08 : 1.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            opacity: active ? 1.0 : 0.55,
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                text[index],
                style: GoogleFonts.syne(
                  fontSize: 120,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  shadows: active
                      ? [
                          Shadow(
                            color: AppColors.glassBorderHover,
                            blurRadius: 18,
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}