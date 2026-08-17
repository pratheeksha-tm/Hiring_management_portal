import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/utils/colors.dart';
// import 'colors.dart'; // adjust path to your actual AppColors location
// import 'package:landpage/src/forms/login.dart';
// import 'login.dart'; // AuthService lives here

void showGuidelineDialog(
  BuildContext context, {
  String initialEmail = '',
}) {
  // final TextEditingController resetEmailController =
  //     TextEditingController(text: initialEmail);
  // final AuthService authService = AuthService();

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.barrierOverlay, // black @ 0.4
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: AppColors.glassFill, // white @ 0.08
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.glassBorder, // white @ 0.15
                ),
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _guideline("Join the interview at least 10 minutes early."),
                    _guideline("Ensure your camera and microphone are working."),
                    _guideline("Use a stable internet connection."),
                    _guideline("Sit in a quiet, well-lit environment."),
                    _guideline("Avoid switching tabs during the interview."),
                    _guideline("Keep your face visible throughout the session."),
                    _guideline("Do not use external assistance unless instructed."),
                    _guideline("Dont switch tabs or full screen, it will be monitored during the interview."),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _guideline(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: AppColors.textPrimary,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: AppColors.chipLabel, // white @ 0.70
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}