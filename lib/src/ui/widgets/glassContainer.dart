import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:landpage/src/utils/colors.dart';
// import 'package:landpage/src/ui/theme/colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.all(20),
    this.color = AppColors.glassFill,
    this.borderColor = AppColors.glassBorder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
