import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/ui/screens/session.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
// import 'package:landpage/src/ui/theme/colors.dart';
import 'package:landpage/src/utils/colors.dart';

const String kIconMicOn = 'icons/mic_on.svg';
const String kIconMicOff = 'icons/mic_off.svg';
const String kIconCameraOn = 'icons/camera_on.svg';
const String kIconCameraOff = 'icons/camera_off.svg';
const String kIconNoCamera = 'icons/no_camera.svg';

enum _CameraLoadState { loading, ready, error, noCameras }

class CameraOverlay extends StatefulWidget {
  final String interviewId;
  const CameraOverlay({super.key, required this.interviewId});

  static Future<void> show(
    BuildContext context, {
    required String interviewId,
  }) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "Camera Overlay",
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) =>
          CameraOverlay(interviewId: interviewId),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay>
    with WidgetsBindingObserver {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  _CameraLoadState _state = _CameraLoadState.loading;
  String? _errorMessage;

  bool _micOn = true;
  bool _cameraOn = true;

  bool _hasInternet = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final hasConnection =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (mounted) setState(() => _hasInternet = hasConnection);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    if (mounted) setState(() => _hasInternet = hasConnection);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Re-init camera when app resumes (handles Android lifecycle correctly).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() => _state = _CameraLoadState.loading);
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() => _state = _CameraLoadState.noCameras);
        return;
      }

      await _startController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      setState(() {
        _state = _CameraLoadState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _startController(CameraDescription description) async {
    final previous = controller;
    controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: _micOn,
    );

    try {
      await controller!.initialize();
      await previous?.dispose();
      if (!mounted) return;
      setState(() => _state = _CameraLoadState.ready);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _CameraLoadState.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _toggleMic() {
    setState(() => _micOn = !_micOn);
  }

  Future<void> _toggleCamera() async {
    if (_cameraOn) {
      // Turning OFF.
      setState(() => _cameraOn = false);
      final toDispose = controller;
      controller = null;
      await toDispose?.dispose();
      return;
    }

    // Turning ON — reinitialize a fresh controller for the current camera.
    setState(() => _cameraOn = true);
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    if (_cameras.isNotEmpty) {
      await _startController(_cameras[_selectedCameraIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final popupWidth = screenSize.width < 560 ? screenSize.width * 0.92 : 520.0;
    final popupHeight = (screenSize.height * 0.85).clamp(520.0, 780.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: popupWidth,
            maxHeight: popupHeight,
          ),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: AppColors.accentGradient
                    .map((c) => c.withValues(alpha: 0.55))
                    .toList(),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26.5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('images/land1.png', fit: BoxFit.cover),
                  Container(
                    color: AppColors.overlayTint.withValues(alpha: 0.65),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(context),
                        const SizedBox(height: 8),
                        Expanded(child: Center(child: _buildCameraCard())),
                        const SizedBox(height: 14),
                        _buildControls(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassFill06,
              border: Border.all(color: AppColors.cardGradientStart),
            ),
            child: const Icon(
              CupertinoIcons.back,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          "Mock Interview",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 520
            ? 480.0
            : constraints.maxWidth;
        return Container(
          width: maxWidth,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: AppColors.accentLinearGradient,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.5),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.cameraCardBg),
                  _buildPreviewContent(),
                  // Bottom label chip
                  Positioned(left: 14, bottom: 14, child: _buildNameChip()),
                  // Mic status dot, top-right
                  Positioned(top: 14, right: 14, child: _buildMicIndicator()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent() {
    if (!_hasInternet) {
      return _buildStatusPanel(
        icon: const Icon(
          CupertinoIcons.wifi_slash,
          color: AppColors.textSecondary,
          size: 24,
        ),
        spinner: false,
        title: "No internet connection",
        subtitle: "Please check your network and try again.",
        showRetry: true,
        onRetry: _checkInitialConnectivity,
      );
    }
    switch (_state) {
      case _CameraLoadState.loading:
        return _buildStatusPanel(
          icon: null,
          spinner: true,
          title: "Setting up camera…",
          subtitle: "This will only take a moment",
        );

      case _CameraLoadState.noCameras:
        return _buildStatusPanel(
          icon: SvgPicture.asset(
            kIconNoCamera,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          spinner: false,
          title: "No camera found",
          subtitle: "This device doesn't have an available camera.",
        );

      case _CameraLoadState.error:
        return _buildStatusPanel(
          icon: const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: AppColors.textSecondary,
            size: 24,
          ),
          spinner: false,
          title: "Couldn't access camera",
          subtitle: _errorMessage ?? "Check permissions and try again.",
          showRetry: true,
        );

      case _CameraLoadState.ready:
        if (!_cameraOn) {
          return _buildStatusPanel(
            icon: SvgPicture.asset(
              kIconCameraOff,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            spinner: false,
            title: "Camera is off",
            subtitle: "Tap the camera icon below to turn it back on.",
          );
        }
        if (controller == null || !controller!.value.isInitialized) {
          return _buildStatusPanel(
            icon: null,
            spinner: true,
            title: "Resuming camera…",
            subtitle: null,
          );
        }
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.previewSize?.height ?? 1,
            height: controller!.value.previewSize?.width ?? 1,
            child: CameraPreview(controller!),
          ),
        );
    }
  }

  Widget _buildStatusPanel({
    required Widget? icon,
    required bool spinner,
    required String title,
    String? subtitle,
    bool showRetry = false,
    VoidCallback? onRetry,
  }) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spinner)
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textFaded80,
                ),
              ),
            )
          else if (icon != null)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassFill,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Center(child: icon),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textFaded55,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          if (showRetry) ...[
            const SizedBox(height: 18),
            SizedBox(
              height: 38,
              child: OutlinedButton(
                onPressed: onRetry ?? _initCamera,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.outlineBorder),
                  backgroundColor: AppColors.inputFill,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(
                  "Try again",
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNameChip() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(
            "You",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicIndicator() {
    final color = _micOn
        ? AppColors.statusCompletedInterview
        : AppColors.statusCancelledInterview;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.black.withValues(alpha: 0.35),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Center(
        child: SvgPicture.asset(
          _micOn ? kIconMicOn : kIconMicOff,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(
            AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return GlassContainer(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            iconBuilder: (color) => SvgPicture.asset(
              _micOn ? kIconMicOn : kIconMicOff,
              width: 19,
              height: 19,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            active: _micOn,
            onTap: _toggleMic,
          ),
          const SizedBox(width: 16),
          _ControlButton(
            iconBuilder: (color) => SvgPicture.asset(
              _cameraOn ? kIconCameraOn : kIconCameraOff,
              width: 19,
              height: 19,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            active: _cameraOn,
            onTap: _toggleCamera,
          ),
          const SizedBox(width: 16),
          const SizedBox(width: 24),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: AppColors.accentLinearGradient,
      ),
      child: ElevatedButton.icon(
        onPressed: (_state == _CameraLoadState.ready && _hasInternet)
            ? () {
                Navigator.of(context).pop(); // close the camera overlay dialog
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => InterviewSessionScreen(
                      initialMicOn: _micOn,
                      initialCameraOn: _cameraOn,
                      interviewId: widget.interviewId,
                    ),
                  ),
                );
              }
            : null,
        icon: const Icon(
          CupertinoIcons.play_fill,
          size: 16,
          color: AppColors.textPrimary,
        ),
        label: Text(
          "Join",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: AppColors.glassBorder,
          disabledBackgroundColor: AppColors.glassFill06,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.5),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final Widget Function(Color color) iconBuilder;
  final bool active;
  final bool neutral;
  final VoidCallback onTap;

  const _ControlButton({
    required this.iconBuilder,
    required this.active,
    required this.onTap,
    this.neutral = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color iconColor;

    if (neutral) {
      bg = AppColors.glassFill;
      iconColor = AppColors.textSecondary;
    } else if (active) {
      bg = AppColors.cardGradientStart;
      iconColor = AppColors.textPrimary;
    } else {
      bg = AppColors.statusCancelledInterview.withValues(alpha: 0.15);
      iconColor = AppColors.statusCancelledInterview;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(
            color: neutral
                ? AppColors.glassBorder
                : (active
                      ? AppColors.glassBorder
                      : AppColors.statusCancelledInterview.withValues(
                          alpha: 0.4,
                        )),
          ),
        ),
        child: Center(child: iconBuilder(iconColor)),
      ),
    );
  }
}
