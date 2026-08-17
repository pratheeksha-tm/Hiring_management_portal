import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:landpage/src/ui/screens/auth_gate.dart';
import 'package:landpage/src/ui/screens/openroles.dart';
import 'package:landpage/src/utils/colors.dart';
import 'firebase_options.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/ui/custom/custom_appbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LandingPage(),
      home: const AuthGate(),
      // home: const AdminPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  bool isAtBottom = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      bool bottom =
          _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 10;

      if (bottom != isAtBottom) {
        setState(() {
          isAtBottom = bottom;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('images/land.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const CustomAppBar(),

                  const SizedBox(height: 100),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 20,
                          decoration: BoxDecoration(
                            color: AppColors.badgePurple.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            "+",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          ' Combinator W24 • 35M+ raised',
                          style: TextStyle(
                            color: AppColors.subtitleText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hiring bold humans to build\nthe best future employees',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 44,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Every great company of the next decade will be built by exceptional employees.\n'
                    'We\'re connecting talented professionals with opportunity that matter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtitleText,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: AppColors.buttonFg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OpenRolesPage(),
                        ),
                      );
                    },
                    child: const Text('See open roles →'),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: SizedBox(
                      height: 90,
                      width: 300,
                      child: Stack(
                        children: const [
                          Positioned(
                            left: 0,
                            child: HoverAvatar(imagePath: 'images/a1.png'),
                          ),
                          Positioned(
                            left: 70,
                            child: HoverAvatar(imagePath: 'images/a2.png'),
                          ),
                          Positioned(
                            left: 140,
                            child: HoverAvatar(imagePath: 'images/a3.png'),
                          ),
                          Positioned(
                            left: 210,
                            child: HoverAvatar(imagePath: 'images/a4.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'WORK WITH TOP TALENTS',
                    style: TextStyle(
                      color: AppColors.sectionLabel,
                      letterSpacing: 1.4,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 45),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 280,
                            height: 420,
                            child: FeatureCard(
                              image: "images/collaboration.png",
                              title: "Effortless\nCollaboration.",
                              description:
                                  "Connect, share, and build together in real-time.",
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 280,
                            height: 420,
                            child: FeatureCard(
                              image: "images/dashboard.png",
                              title: "Visualize Your\nProgress.",
                              description:
                                  "Track performance with dynamic analytics & intuitive dashboards.",
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 280,
                            height: 420,
                            child: FeatureCard(
                              image: "images/automation.png",
                              title: "Smart\nAutomation.",
                              description:
                                  "Automate workflows and save time with intelligent task management.",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ScrollProgressFAB(scrollController: _scrollController),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final String image;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..scale(hovered ? 1.05 : 1.0)
          ..translate(0, hovered ? -8 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
          ),
          border: Border.all(
            color: hovered ? AppColors.cardBorderHover : AppColors.cardBorder,
            width: 1.2,
          ),
          boxShadow: hovered
              ? [
                  BoxShadow(
                    color: AppColors.cardShadowHover,
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.cardShadowNormal,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      widget.image,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.6,
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
}

class NavTextItem extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const NavTextItem({super.key, required this.title, this.onTap});

  @override
  State<NavTextItem> createState() => _NavTextItemState();
}

class _NavTextItemState extends State<NavTextItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 1.5,
                width: isHovered ? 35 : 0,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverAvatar extends StatefulWidget {
  final String imagePath;

  const HoverAvatar({super.key, required this.imagePath});

  @override
  State<HoverAvatar> createState() => _HoverAvatarState();
}

class _HoverAvatarState extends State<HoverAvatar> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: AppColors.avatarShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.badgePurple, width: 1),
              image: DecorationImage(
                image: AssetImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScrollProgressFAB extends StatefulWidget {
  final ScrollController scrollController;
  const ScrollProgressFAB({super.key, required this.scrollController});

  @override
  State<ScrollProgressFAB> createState() => _ScrollProgressFABState();
}

class _ScrollProgressFABState extends State<ScrollProgressFAB>
    with TickerProviderStateMixin {
  double _progress = 0.0; // 0 = top, 1 = bottom
  bool _visible = false;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final offset = position.pixels;

    final newProgress = maxScroll <= 0
        ? 0.0
        : (offset / maxScroll).clamp(0.0, 1.0);
    final shouldShow = offset > 150; // appear only after some scrolling

    if (newProgress == _progress && shouldShow == _visible) return;

    setState(() {
      _progress = newProgress;
      if (shouldShow && !_visible) {
        _entranceController.forward(from: 0);
      } else if (!shouldShow && _visible) {
        _entranceController.reverse();
      }
      _visible = shouldShow;
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _entranceController.dispose();
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.scrollController.hasClients) return;
    final atBottom = _progress > 0.96;

    widget.scrollController.animateTo(
      atBottom ? 0 : widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final atBottom = _progress > 0.96;

    return IgnorePointer(
      ignoring: !_visible,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _entranceController,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeIn,
        ),
        child: FadeTransition(
          opacity: _entranceController,
          child: GestureDetector(
            onTapDown: (_) => _pressController.forward(),
            onTapUp: (_) {
              _pressController.reverse();
              _handleTap();
            },
            onTapCancel: () => _pressController.reverse(),
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _pressController]),
              builder: (context, child) {
                final pulse = 1 + (_pulseController.value * 0.05);
                final press = 1 - (_pressController.value * 0.15);
                return Transform.scale(scale: pulse * press, child: child);
              },
              child: SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Soft glow that intensifies as you near the bottom
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.fabGlow.withValues(
                              alpha: 0.35 + _progress * 0.25,
                            ),
                            blurRadius: 20 + (_progress * 10),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    // Circular scroll-progress ring
                    CustomPaint(
                      size: const Size(60, 60),
                      painter: _ProgressRingPainter(progress: _progress),
                    ),

                    // Glass core with morphing arrow icon
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.fabCoreGradientStart,
                                AppColors.fabCoreGradientEnd,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.glassBorderHover,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: Transform.rotate(
                                key: ValueKey(atBottom),
                                angle: atBottom
                                    ? 0
                                    : 3.14159, // 180° flip when at bottom
                                child: SvgPicture.asset(
                                  'icons/mouse.svg',
                                  key: ValueKey(atBottom),
                                  width: 22,
                                  height: 22,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;

    final trackPaint = Paint()
      ..color = AppColors.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          AppColors.ringAccent,
          AppColors.textPrimary,
          AppColors.ringAccent,
        ],
        startAngle: 0,
        endAngle: 6.28319,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const startAngle = -1.5708; // start at 12 o'clock
    final sweepAngle = 6.28319 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
