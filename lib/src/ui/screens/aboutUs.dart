import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/ui/custom/custom_appbar.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/ui/screens/contactUs.dart';
import 'package:landpage/src/utils/colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBar(isAboutPage: true),
                  const SizedBox(height: 48),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Artisan',
                          style: GoogleFonts.poppins(
                            color: AppColors.textFaded65,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'We help people find work\nthat actually fits.',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 36,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Text(
                            "Artisan started in 2022 with a simple belief: finding the right "
                            "opportunity, or the right person, shouldn't feel like a second job. "
                            "We're a small, focused team building tools that make hiring faster, "
                            "fairer.",
                            style: GoogleFonts.poppins(
                              color: AppColors.subtitleText,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Container(height: 1, color: AppColors.glassBorder),
                        const SizedBox(height: 32),

                        // ---------- Stats, plain text, spread full width ----------
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            const stats = [
                              _StatData(value: '2022', label: 'Founded'),
                              _StatData(value: '18', label: 'Team members'),
                              _StatData(
                                value: '4.2k',
                                label: 'Companies onboarded',
                              ),
                              _StatData(
                                value: '12',
                                label: 'Countries reached',
                              ),
                            ];
                            final items = stats
                                .map((s) => Expanded(child: _StatItem(data: s)))
                                .toList();
                            return isWide
                                ? Row(children: items)
                                : Wrap(
                                    spacing: 24,
                                    runSpacing: 16,
                                    children: stats
                                        .map((s) => _StatItem(data: s))
                                        .toList(),
                                  );
                          },
                        ),

                        const SizedBox(height: 32),
                        Container(height: 1, color: AppColors.glassBorder),
                        const SizedBox(height: 32),

                        // ---------- Values, two-column on wide screens ----------
                        Text(
                          'What we value',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 700;
                            const rows = [
                              _ValueRow(
                                index: '01',
                                title: 'Move with purpose',
                                body:
                                    "We ship small, ship often, and cut anything that "
                                    "doesn't serve the people using it.",
                              ),
                              _ValueRow(
                                index: '02',
                                title: 'Built on trust',
                                body:
                                    "Transparent process, honest communication, no "
                                    "dark patterns — with users or each other.",
                              ),
                              _ValueRow(
                                index: '03',
                                title: 'Sweat the details',
                                body:
                                    "Good enough isn't. We care about the small "
                                    "things because that's where trust is built.",
                              ),
                            ];
                            if (!isWide) {
                              return Column(
                                children: [
                                  for (final r in rows) ...[
                                    r,
                                    const SizedBox(height: 18),
                                  ],
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < rows.length; i++) ...[
                                  Expanded(child: rows[i]),
                                  if (i != rows.length - 1)
                                    const SizedBox(width: 32),
                                ],
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 36),

                        GlassContainer(
                          radius: 20,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 22,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 500;
                              final text = Text(
                                'Want to work with us?',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                              final button = _CtaButton(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ContactUsPage(),
                                    ),
                                  );
                                },
                              );
                              return isWide
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [text, button],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        text,
                                        const SizedBox(height: 16),
                                        button,
                                      ],
                                    );
                            },
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String value;
  final String label;
  const _StatData({required this.value, required this.label});
}

class _StatItem extends StatelessWidget {
  final _StatData data;
  const _StatItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.value,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.label,
          style: GoogleFonts.poppins(
            color: AppColors.textFaded65,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

// ---------------- Value row (plain text, no box) ----------------

class _ValueRow extends StatelessWidget {
  final String index;
  final String title;
  final String body;

  const _ValueRow({
    required this.index,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            index,
            style: GoogleFonts.poppins(
              color: AppColors.textFaded50,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: GoogleFonts.poppins(
                  color: AppColors.textFaded65,
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- CTA pill button ----------------

class _CtaButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CtaButton({required this.onTap});

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.only(left: 22, right: 6, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: AppColors.accentGradient[1].withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: AppColors.fabGlow.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact Us',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textPrimary,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.accentMid,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
