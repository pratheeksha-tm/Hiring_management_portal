import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/forms/login.dart';
import 'package:landpage/src/utils/colors.dart';
// import 'package:landpage/src/ui/theme/colors.dart'; // adjust path if different
// import 'login.dart'; // AuthService lives here

void showForgotPasswordDialog(
  BuildContext context, {
  String initialEmail = '',
}) {
  final TextEditingController resetEmailController =
      TextEditingController(text: initialEmail);
  final AuthService authService = AuthService();

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.barrierOverlay,
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
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.glassBorder,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reset Password",
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email and we'll send you a reset link.",
                    style: GoogleFonts.poppins(
                      color: AppColors.textFaded65,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: resetEmailController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        CupertinoIcons.mail_solid,
                        color: AppColors.textSecondary,
                      ),
                      hintText: "Email",
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.sectionLabel,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: AppColors.glassBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.removeButtonBorder,
                              ),
                              backgroundColor:
                                  AppColors.outlineBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              gradient: const LinearGradient(
                                colors: AppColors.accentGradient,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                authService.resetPassword(
                                  context: context,
                                  emailController: resetEmailController,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    AppColors.glassFillHover,
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: Text(
                                "Send Link",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}