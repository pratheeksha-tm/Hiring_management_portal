import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/utils/colors.dart';

class InterviewerPip extends StatefulWidget {
  final BoxConstraints constraints;
  final String photoAsset;
  final String name;
  const InterviewerPip({
    super.key,
    required this.constraints,
    this.photoAsset = 'images/interviewer.png',
    this.name = 'Interviewer',
  });

  @override
  State<InterviewerPip> createState() => _InterviewerPipState();
}

class _InterviewerPipState extends State<InterviewerPip> {
  static const double _pipWidth = 108;
  static const double _pipHeight = 138;

  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    final constraints = widget.constraints;

    // Default spot: top-right corner. Only set once so drags aren't overridden.
    _offset ??= Offset(constraints.maxWidth - _pipWidth - 14, 14);

    return Positioned(
      left: _offset!.dx,
      top: _offset!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newX = (_offset!.dx + details.delta.dx).clamp(
              0.0,
              constraints.maxWidth - _pipWidth,
            );
            final newY = (_offset!.dy + details.delta.dy).clamp(
              0.0,
              constraints.maxHeight - _pipHeight,
            );
            _offset = Offset(newX, newY);
          });
        },
        child: Container(
          width: _pipWidth,
          height: _pipHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(widget.photoAsset, fit: BoxFit.cover),

                // Name chip, bottom-left
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          widget.name,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Muted mic/camera strip, top-right,
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _pipMiniIcon('icons/mic_off.svg'),
                      const SizedBox(width: 4),
                      _pipMiniIcon('icons/camera_off.svg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pipMiniIcon(String asset) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.black.withValues(alpha: 0.35),
        border: Border.all(
          color: AppColors.statusCancelledInterview.withValues(alpha: 0.6),
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: 10,
          height: 10,
          colorFilter: const ColorFilter.mode(
            AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
