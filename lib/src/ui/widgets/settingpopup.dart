import 'dart:ui';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landpage/src/ui/theme/colors.dart';
import 'package:landpage/src/utils/colors.dart';

Widget _glassDialogFrame({
  required BuildContext dialogContext,
  required String title,
  required String description,
  required Widget content,
  required String confirmLabel,
  required VoidCallback? onConfirm,
}) {
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
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  color: AppColors.textFaded65,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 22),
              content,
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.removeButtonBorder),
                          backgroundColor: AppColors.outlineBg,
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
                          gradient: LinearGradient(
                            colors: onConfirm != null
                                ? AppColors.accentGradient
                                : AppColors.accentGradient
                                      .map((c) => c.withValues(alpha: .35))
                                      .toList(),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: onConfirm == null
                              ? null
                              : () {
                                  Navigator.of(dialogContext).pop();
                                  onConfirm();
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.glassFillHover,
                            disabledBackgroundColor: AppColors.glassFill06,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Text(
                            confirmLabel,
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
}

Future<void> showGlassFieldDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String hintText,
  required IconData icon,
  String initialValue = '',
  bool obscureText = false,
  String confirmLabel = "Update",
  bool requireCurrentPassword = false,
  required void Function(String value, String currentPassword) onConfirm,
}) {
  final controller = TextEditingController(text: initialValue);
  final currentPasswordController = TextEditingController();

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.barrierOverlay,
    builder: (dialogContext) {
      return _glassDialogFrame(
        dialogContext: dialogContext,
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (requireCurrentPassword) ...[
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    CupertinoIcons.lock_fill,
                    color: AppColors.textSecondary,
                  ),
                  hintText: "Current password",
                  hintStyle: GoogleFonts.poppins(color: AppColors.sectionLabel),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.textSecondary),
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(color: AppColors.sectionLabel),
                filled: true,
                fillColor: AppColors.inputFill,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
        onConfirm: () => onConfirm(
          controller.text.trim(),
          currentPasswordController.text.trim(),
        ),
      );
    },
  );
}

Future<void> showResumeUploadDialog({
  required BuildContext context,
  String? currentFileName,
  required void Function(PlatformFile file) onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.barrierOverlay,
    builder: (dialogContext) {
      PlatformFile? picked;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickFile() async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx'],
            );
            if (result != null && result.files.isNotEmpty) {
              setDialogState(() => picked = result.files.first);
            }
          }

          return _glassDialogFrame(
            dialogContext: dialogContext,
            title: "Upload Resume",
            description:
                "Choose a PDF or Word document (up to 5MB) for recruiters to review.",
            confirmLabel: picked != null ? "Upload" : "Choose file",
            content: GestureDetector(
              onTap: picked == null ? pickFile : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: AppColors.accentGradient
                              .map((c) => c.withValues(alpha: 0.35))
                              .toList(),
                        ),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Icon(
                        picked != null
                            ? CupertinoIcons.doc_text_fill
                            : CupertinoIcons.cloud_upload,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            picked?.name ??
                                currentFileName ??
                                "No file selected",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            picked != null
                                ? "Ready to upload"
                                : "Tap to browse files",
                            style: GoogleFonts.poppins(
                              color: AppColors.textFaded50,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (picked != null)
                      TextButton(
                        onPressed: pickFile,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentLight,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Change",
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            onConfirm: picked == null ? null : () => onConfirm(picked!),
          );
        },
      );
    },
  );
}

Future<void> showAvatarUploadDialog({
  required BuildContext context,
  Uint8List? currentImageBytes,
  required void Function(Uint8List bytes) onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.barrierOverlay,
    builder: (dialogContext) {
      Uint8List? picked = currentImageBytes;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final XFile? file = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 85,
              maxWidth: 800,
              maxHeight: 800,
            );
            if (file != null) {
              final bytes = await file.readAsBytes();
              setDialogState(() => picked = bytes);
            }
          }

          final bool hasNewImage =
              picked != null && picked != currentImageBytes;

          return _glassDialogFrame(
            dialogContext: dialogContext,
            title: "Update Profile Picture",
            description: "Choose an image to use as your profile picture.",
            confirmLabel: hasNewImage ? "Save" : "Choose photo",
            content: GestureDetector(
              onTap: pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: picked == null
                            ? AppColors.accentLinearGradient
                            : null,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      alignment: Alignment.center,
                      child: picked != null
                          ? ClipOval(
                              child: Image.memory(
                                picked!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.cloud_upload,
                              color: AppColors.textPrimary,
                              size: 18,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            picked != null
                                ? "Photo selected"
                                : "No photo selected",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            picked != null
                                ? "Tap to change"
                                : "Tap to browse photos",
                            style: GoogleFonts.poppins(
                              color: AppColors.textFaded50,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (picked != null)
                      TextButton(
                        onPressed: pickImage,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentLight,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Change",
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            onConfirm: hasNewImage ? () => onConfirm(picked!) : null,
          );
        },
      );
    },
  );
}

Future<void> showLogoutDialog({
  required BuildContext context,
  required Widget registerPage,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.barrierOverlay,
    builder: (dialogContext) {
      return _glassDialogFrame(
        dialogContext: dialogContext,
        title: "Log out of all devices",
        description:
            "This will sign you out from all devices where you're currently logged in. You'll need to sign in again on each device.",
        confirmLabel: "Log out",
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.statusCancelledInterview.withValues(
                    alpha: 0.12,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.square_arrow_right,
                  color: AppColors.statusCancelledInterview,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "All active sessions will be ended immediately.",
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        onConfirm: () {
          // TODO: Add logout logic later
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => registerPage),
            (route) => false,
          );
        },
      );
    },
  );
}
