import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/ui/widgets/interviewerpic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
// import 'package:landpage/src/ui/theme/colors.dart';
import 'package:landpage/src/utils/colors.dart';

const List<Color> kSessionAccentGradient = AppColors.accentGradient;

class InterviewSessionScreen extends StatefulWidget {
  final bool initialMicOn;
  final bool initialCameraOn;

  final String interviewId;

  const InterviewSessionScreen({
    super.key,
    this.initialMicOn = true,
    this.initialCameraOn = true,
    required this.interviewId,
  });

  @override
  State<InterviewSessionScreen> createState() => _InterviewSessionScreenState();
}

class _ChatMessage {
  final String sender;
  final String text;
  final DateTime time;

  _ChatMessage({required this.sender, required this.text, required this.time});

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'time': time.toIso8601String(),
  };

  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _ChatMessage(
    sender: json['sender'] as String,
    text: json['text'] as String,
    time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
  );
}

class _InterviewSessionScreenState extends State<InterviewSessionScreen> {
  CameraController? _controller;
  bool _cameraReady = false;
  late bool _micOn = widget.initialMicOn;
  late bool _cameraOn = widget.initialCameraOn;

  // --- Timer ---
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  String get _chatPrefsKey => 'interview_chat_messages_${widget.interviewId}';
  final List<_ChatMessage> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _chatLoading = true;

  @override
  void initState() {
    super.initState();

    if (_cameraOn) {
      _initCamera();
    }
    _startTimer();
    _loadChatMessages();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: _micOn,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  void _toggleMic() => setState(() => _micOn = !_micOn);

  Future<void> _toggleCamera() async {
    if (_cameraOn) {
      setState(() => _cameraOn = false);
      final toDispose = _controller;
      _controller = null;
      _cameraReady = false;
      await toDispose?.dispose();
      return;
    }
    setState(() => _cameraOn = true);
    await _initCamera();
  }

  Future<void> _loadChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatPrefsKey);
    if (!mounted) return;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _messages.addAll(
          decoded.map((e) => _ChatMessage.fromJson(e as Map<String, dynamic>)),
        );
      } catch (_) {}
    }
    setState(() => _chatLoading = false);
    _scrollToBottom();
  }

  Future<void> _saveChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString(_chatPrefsKey, raw);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(sender: 'you', text: text, time: DateTime.now()),
      );
    });
    _chatController.clear();
    _saveChatMessages();
    _scrollToBottom();
  }

  String get _formattedTime {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  String get _userInitial {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) return "?";
    return email[0].toUpperCase();
  }

  void _confirmEndInterview() {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(24),
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
                      "End interview?",
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You won't be able to resume this session once you leave.",
                      style: GoogleFonts.poppins(
                        color: AppColors.textFaded65,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.removeButtonBorder,
                                ),
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors
                                    .statusCancelledInterview
                                    .withValues(alpha: 0.85),
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: Text(
                                "End",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('images/land1.png', fit: BoxFit.cover),
          Container(color: AppColors.overlayTint.withValues(alpha: 0.72)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 3, child: _buildVideoTile()),
                              const SizedBox(width: 20),
                              Expanded(flex: 2, child: _buildChatPanel()),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Expanded(flex: 3, child: _buildVideoTile()),
                            const SizedBox(height: 16),
                            Expanded(flex: 2, child: _buildChatPanel()),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildControlsBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.statusCancelledInterview,
          ),
        ),
        Text(
          "Live · Mock Interview",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.clock,
                color: AppColors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _formattedTime,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTile() {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: kSessionAccentGradient),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.cameraCardBg),
                if (_cameraOn && _cameraReady && _controller != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      height: 100 / _controller!.value.aspectRatio,
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: kSessionAccentGradient,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _userInitial,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _cameraOn ? "Starting camera…" : "Camera is off",
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black.withValues(alpha: 0.35),
                      border: Border.all(
                        color:
                            (_micOn
                                    ? AppColors.statusCompletedInterview
                                    : AppColors.statusCancelledInterview)
                                .withValues(alpha: 0.6),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        _micOn ? 'icons/mic_on.svg' : 'icons/mic_off.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),

                InterviewerPip(constraints: constraints),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatPanel() {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: kSessionAccentGradient
                        .map((c) => c.withValues(alpha: 0.35))
                        .toList(),
                  ),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Chat",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                "${_messages.length} messages",
                style: GoogleFonts.poppins(
                  color: AppColors.textFaded50,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _chatLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Text(
                      "No messages yet — say hello.",
                      style: GoogleFonts.poppins(
                        color: AppColors.textFaded50,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: _chatScrollController,
                    itemCount: _messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isYou = msg.sender == 'you';
                      return Align(
                        alignment: isYou
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isYou
                                ? AppColors.accentMid.withValues(alpha: 0.35)
                                : AppColors.glassFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Text(
                            msg.text,
                            style: GoogleFonts.poppins(
                              color: AppColors.textEmphasis92,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _sendMessage(),
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                    ),
                    decoration: InputDecoration(
                      hintText: "Type a message…",
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textFaded40,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: const LinearGradient(
                    colors: kSessionAccentGradient,
                  ),
                ),
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(11.5),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.glassFillHover,
                      borderRadius: BorderRadius.circular(11.5),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_up,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return GlassContainer(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SessionControlButton(
            iconAsset: _micOn ? 'icons/mic_on.svg' : 'icons/mic_off.svg',
            active: _micOn,
            onTap: _toggleMic,
          ),
          const SizedBox(width: 16),
          _SessionControlButton(
            iconAsset: _cameraOn
                ? 'icons/camera_on.svg'
                : 'icons/camera_off.svg',
            active: _cameraOn,
            onTap: _toggleCamera,
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  AppColors.statusCancelledInterview.withValues(alpha: 0.9),
                  AppColors.endCallGradientEnd.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: _confirmEndInterview,
              icon: const Icon(
                CupertinoIcons.phone_down_fill,
                size: 16,
                color: AppColors.textPrimary,
              ),
              label: Text(
                "End",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: AppColors.glassFillHover,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionControlButton extends StatelessWidget {
  final String iconAsset;
  final bool active;
  final VoidCallback onTap;

  const _SessionControlButton({
    required this.iconAsset,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? AppColors.cardGradientStart
        : AppColors.statusCancelledInterview.withValues(alpha: 0.15);
    final iconColor = active
        ? AppColors.textPrimary
        : AppColors.statusCancelledInterview;
    final borderColor = active
        ? AppColors.glassBorder
        : AppColors.statusCancelledInterview.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: 19,
            height: 19,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
