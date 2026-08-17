import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---- Core accent gradient  ----
  static const Color accentLight = Color(0xffC084FC);
  static const Color accentMid = Color(0xffA855F7);
  static const Color accentDark = Color(0xff6D28D9);

  static const List<Color> accentGradient = [
    accentLight,
    accentMid,
    accentDark,
  ];

  static const LinearGradient accentLinearGradient = LinearGradient(
    colors: accentGradient,
  );

  // ---- Glass surfaces ----
  static const Color glassFill = Color(0x14FFFFFF); // white @ ~0.08
  static const Color glassFillHover = Color(0x24FFFFFF); // white @ ~0.14
  static const Color glassBorder = Color(0x26FFFFFF); // white @ ~0.15
  static const Color glassBorderHover = Color(0x59FFFFFF); // white @ ~0.35

  // ---- Text ----
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white38;

  // ---- Status / misc ----
  static const Color destructive = Color(0xffFF8A8A);
  static const Color glowPurple = Color(0xffA855F7);

  // ---- Found in main.dart ----
  static const Color badgePurple =
      Colors.purple; // YC pill + HoverAvatar border
  static const Color fabGlow = Color.fromARGB(
    255,
    163,
    141,
    167,
  ); // ScrollProgressFAB glow
  static const Color ringAccent =
      Colors.purpleAccent; // progress ring sweep gradient

  // ---- Found in main.dart (round 2) ----
  static const Color badgeBg =
      glassBorder; // white @ 0.15 — badge pill background (reused)
  static const Color subtitleText = Color(
    0xBFFFFFFF,
  ); // white @ 0.75 — hero subtitle & badge label
  static const Color sectionLabel = Color(
    0x99FFFFFF,
  ); // white @ 0.6 — "WORK WITH TOP TALENTS"
  static const Color buttonFg = Colors.black; // "See open roles" button text

  static const Color cardGradientStart = Color(0x1FFFFFFF); // white @ 0.12
  static const Color cardGradientEnd = Color(0x08FFFFFF); // white @ 0.03
  static const Color cardBorder = Color(0x1AFFFFFF); // white @ 0.1
  static const Color cardBorderHover = Color(0x4DFFFFFF); // white @ 0.3
  static const Color cardShadowHover = Color(0x40000000); // black @ 0.25
  static const Color cardShadowNormal = Color(0x0D000000); // black @ 0.05

  static const Color avatarShadow = Color(0x4D000000); // black @ 0.3

  static const Color fabCoreGradientStart = Color(0x38FFFFFF); // white @ 0.22
  static const Color fabCoreGradientEnd = Color(0x0FFFFFFF); // white @ 0.06

  // ---- register.dart ----
  static const Color inputFill = Color(
    0x0DFFFFFF,
  ); // white @ 0.05 — text field fill

  // ---- dashboard.dart ----
  static const Color textEmphasis90 = Color(
    0xE6FFFFFF,
  ); // white @ 0.9 — activity title, dropdown tile fg
  static const Color textFaded65 = Color(
    0xA6FFFFFF,
  ); // white @ 0.65 — stat card label
  static const Color textFaded55 = Color(
    0x8CFFFFFF,
  ); // white @ 0.55 — dropdown menu email
  static const Color textFaded50 = Color(
    0x80FFFFFF,
  ); // white @ 0.5 — activity time
  static const Color outlineBorder = Color(
    0x33FFFFFF,
  ); // white @ 0.2 — outline button border
  static const Color outlineBg = Color(
    0x0AFFFFFF,
  ); // white @ 0.04 — outline button bg

  // ---- Found in company.dart ----
  static const Color textFaded40 = Color(
    0x66FFFFFF,
  ); // white @ 0.4 — hint text, empty-state icon
  static const Color textFaded45 = Color(
    0x73FFFFFF,
  ); // white @ 0.45 — search icons
  static const Color shadowPurpleDeep = Color(
    0xff7C3AED,
  ); // deep purple glow behind company icon
  static const Color success = Color(0xff34D399); // "Applied" badge
  static const Color glassFill07 = Color(
    0x12FFFFFF,
  ); // white @ 0.07 — unselected filter chip bg
  static const Color glassFill06 = Color(
    0x0FFFFFFF,
  ); // white @ 0.06 — role chip bg

  // ---- Base ----
  static const Color white =
      Colors.white; // raw white for one-off .withOpacity() calls

  // ----  applications.dart ----
  static const Color statusApplied = Color.fromARGB(
    255,
    228,
    135,
    219,
  ); // "Applied" status pill/dot/accent bar
  static const Color statusUnderReview = Color.fromARGB(
    255,
    159,
    195,
    239,
  ); // "Under Review" status pill/dot/accent bar
  static const Color statusInterview = Color.fromARGB(
    255,
    227,
    207,
    154,
  ); // "Interview" status pill/dot/accent bar
  static const Color statusOffer = Color.fromARGB(
    255,
    144,
    211,
    187,
  ); // "Offer" status pill/dot/accent bar
  static const Color statusRejected = Color.fromARGB(
    255,
    239,
    167,
    167,
  ); // "Rejected" status pill/dot/accent bar
  static const Color shaderHighlight = Color(
    0xffE9D5FF,
  ); // "Applications Sent" header shader gradient end

  // ---- selected_roles.dart ----
  static const Color removeButtonBorder = Color(
    0x2EFFFFFF,
  ); // white @ 0.18 — Remove button border
  static const Color appliedBg = Color(
    0x1AFFFFFF,
  ); // white @ 0.1 — Applied button background (filled state)
  static const Color chipLabel = Color(
    0xB3FFFFFF,
  ); // white @ 0.70 — role chip label text

  // ---- interview status colors (interview.dart + interview_room.dart _StatusBadge) ----
  static const Color statusUpcomingInterview = Color.fromARGB(
    255,
    214,
    142,
    65,
  ); // upcoming badge + early-join dialog icon
  static const Color statusCompletedInterview = Color(
    0xff22C55E,
  ); // completed badge
  static const Color statusCancelledInterview = Color(
    0xffF87171,
  ); // cancelled badge + join-window-over dialog icon

  // ---- interview_room.dart ----
  static const Color barrierOverlay = Color(
    0x66000000,
  ); // black @ 0.4 — dialog barrier/scrim behind popups

  // ---- Additional shared alpha variants (added for color audit) ----
  static const Color textFaded85 = Color(
    0xD9FFFFFF,
  ); // white @ 0.85 — filter chip count text
  static const Color textFaded80 = Color(
    0xCCFFFFFF,
  ); // white @ 0.80 — empty state title text
  static const Color logoutTextColor = Color.fromARGB(
    255,
    236,
    232,
    232,
  ); // destructive dropdown tile text (near-white)
  static const Color tileFillHover = Color(
    0x17FFFFFF,
  ); // white @ ~0.09 — application tile hover fill
  static const Color tileFillBase = Color(
    0x0CFFFFFF,
  ); // white @ ~0.045 — application tile base fill

  // ---- Additional colors found during audit (settings.dart, settingpopup.dart, camera_overlay.dart) ----
  static const Color black = Colors
      .black; // raw black for one-off .withValues() calls (mirrors `white` above)
  static const Color overlayTint = Color(
    0xff0F0A1E,
  ); // dark navy/purple backdrop tint behind camera overlay
  static const Color cameraCardBg = Color(
    0xff17102A,
  ); // camera preview card background

  // ---- Additional colors found in session.dart (interview session screen) ----
  static const Color endCallGradientEnd = Color(
    0xffEF4444,
  ); // darker red, second stop of "End" button gradient (paired with statusCancelledInterview)
  static const Color textEmphasis92 = Color(
    0xEBFFFFFF,
  ); // white @ 0.92 — active interview question text

  // ---- Additional colors found in calendar.dart (time-picker dialog theme) ----
  static const Color datePickerSurface = Color(
    0xff1A1B2E,
  ); // dark surface for the time-picker dialog's ColorScheme.dark
  // add alongside barrierOverlay in AppColors
  static const Color deleteAccountBarrier = Color(
    0x59000000,
  ); // black @ 0.35 — delete-account confirmation dialog barrier
  static const Color snackBarBg = Color(
    0xFF1F1F1F,
  ); // solid dark gray — default snackbar background

  static const Color loadingOverlayBg = Color(
    0xff1a0f2b,
  ); // dark purple-black — LoadingOverlay outer card background
  static const Color loadingOverlayInnerBg = Color(
    0xff130a1f,
  ); // deeper purple-black — LoadingOverlay spinner puck background
}
