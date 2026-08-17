import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/utils/colors.dart' show AppColors;
import 'dashboard.dart' show kAccentGradient;

// import 'package:landpage/src/ui/widgets/offer_email_button.dart';
enum ApplicationStatus { applied, underReview, interview, offer, rejected }

extension _StatusMeta on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return "Applied";
      case ApplicationStatus.underReview:
        return "Under Review";
      case ApplicationStatus.interview:
        return "Interview";
      case ApplicationStatus.offer:
        return "Offer";
      case ApplicationStatus.rejected:
        return "Rejected";
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.applied:
        return AppColors.statusApplied;
      case ApplicationStatus.underReview:
        return AppColors.statusUnderReview;
      case ApplicationStatus.interview:
        return AppColors.statusInterview;
      case ApplicationStatus.offer:
        return AppColors.statusOffer;
      case ApplicationStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.applied:
        return CupertinoIcons.paperplane_fill;
      case ApplicationStatus.underReview:
        return CupertinoIcons.doc_text_search;
      case ApplicationStatus.interview:
        return CupertinoIcons.calendar;
      case ApplicationStatus.offer:
        return CupertinoIcons.checkmark_seal_fill;
      case ApplicationStatus.rejected:
        return CupertinoIcons.xmark_circle_fill;
    }
  }

  int get stageIndex {
    switch (this) {
      case ApplicationStatus.applied:
        return 0;
      case ApplicationStatus.underReview:
        return 1;
      case ApplicationStatus.interview:
        return 2;
      case ApplicationStatus.offer:
        return 3;
      case ApplicationStatus.rejected:
        return 1;
    }
  }
}

class ApplicationData {
  final String role;
  final String company;
  final String appliedOn;
  final ApplicationStatus status;
  final String companyInitial;

  const ApplicationData({
    required this.role,
    required this.company,
    required this.appliedOn,
    required this.status,
    required this.companyInitial,
  });

  // Add this — a stable id used to track "offer email sent" state.
  String get id => "$company|$role|$appliedOn";
}

class ApplicationsSection extends StatefulWidget {
  const ApplicationsSection({super.key});

  @override
  State<ApplicationsSection> createState() => _ApplicationsSectionState();
}

class _ApplicationsSectionState extends State<ApplicationsSection> {
  ApplicationStatus? _filter; // null = "All"
  final Set<String> _sentOfferIds = {};

  List<ApplicationData> get _applications => const [
    ApplicationData(
      role: "Frontend Engineer",
      company: "Fable Studio",
      appliedOn: "Jul 18, 2026",
      status: ApplicationStatus.interview,
      companyInitial: "F",
    ),
    ApplicationData(
      role: "UX Researcher",
      company: "Fable Studio",
      appliedOn: "Jul 15, 2026",
      status: ApplicationStatus.underReview,
      companyInitial: "F",
    ),
    ApplicationData(
      role: "Frontend Engineer",
      company: "Orbit Robotics",
      appliedOn: "Jul 12, 2026",
      status: ApplicationStatus.applied,
      companyInitial: "O",
    ),
    ApplicationData(
      role: "Frontend Engineer",
      company: "Lumen Health",
      appliedOn: "Jul 05, 2026",
      status: ApplicationStatus.offer,
      companyInitial: "L",
    ),
    ApplicationData(
      role: "UX Designer",
      company: "Lumen Health",
      appliedOn: "Jun 29, 2026",
      status: ApplicationStatus.rejected,
      companyInitial: "L",
    ),
  ];

  Map<ApplicationStatus, int> get _counts {
    final map = <ApplicationStatus, int>{};
    for (final a in _applications) {
      map[a.status] = (map[a.status] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final all = _applications;
    final filtered = _filter == null
        ? all
        : all.where((a) => a.status == _filter).toList();

    return _ApplicationsGlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(all.length),
          const SizedBox(height: 22),
          _buildFilterChips(),
          const SizedBox(height: 22),
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...List.generate(filtered.length, (i) {
              return _AnimatedEntry(
                index: i,
                // child: _ApplicationTile(data: filtered[i]),
                child: _ApplicationTile(
                  key: ValueKey(filtered[i].id), // NEW: stable key
                  data: filtered[i],
                  alreadySent: _sentOfferIds.contains(filtered[i].id), // NEW
                  onOfferSent: () {
                    setState(() => _sentOfferIds.add(filtered[i].id)); // NEW
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: kAccentGradient),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentMid.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            CupertinoIcons.paperplane_fill,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.white, AppColors.shaderHighlight],
              ).createShader(bounds),
              child: Text(
                "Applications Sent",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Track every role you've applied to",
              style: GoogleFonts.poppins(
                color: AppColors.textFaded50,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: kAccentGradient
                  .map((c) => c.withValues(alpha: 0.25))
                  .toList(),
            ),
            border: Border.all(color: AppColors.outlineBorder),
          ),
          child: Text(
            "$total total",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final counts = _counts;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: "All",
            count: _applications.length,
            color: AppColors.white,
            selected: _filter == null,
            onTap: () => setState(() => _filter = null),
          ),
          ...ApplicationStatus.values.map((s) {
            final count = counts[s] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: s.label,
                count: count,
                color: s.color,
                icon: s.icon,
                selected: _filter == s,
                onTap: () => setState(() => _filter = s),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: kAccentGradient
                      .map((c) => c.withValues(alpha: 0.2))
                      .toList(),
                ),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                CupertinoIcons.tray,
                color: AppColors.textFaded50,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Nothing here yet",
              style: GoogleFonts.poppins(
                color: AppColors.textFaded80,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Applications matching this filter will show up here.",
              style: GoogleFonts.poppins(
                color: AppColors.textFaded40,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final int count;
  final Color color;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: active
                ? widget.color.withValues(alpha: 0.18)
                : (hovered ? AppColors.glassFill : AppColors.outlineBg),
            border: Border.all(
              color: active
                  ? widget.color.withValues(alpha: 0.6)
                  : AppColors.cardGradientStart,
              width: active ? 1.3 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 13,
                  color: active ? widget.color : AppColors.sectionLabel,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.cardGradientStart,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${widget.count}",
                  style: GoogleFonts.poppins(
                    color: AppColors.textFaded85,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ApplicationTile extends StatefulWidget {
  final ApplicationData data;
  final bool alreadySent;
  final VoidCallback onOfferSent;
  const _ApplicationTile({
    super.key,
    required this.data,
    required this.alreadySent,
    required this.onOfferSent,
  });

  @override
  State<_ApplicationTile> createState() => _ApplicationTileState();
}

class _ApplicationTileState extends State<_ApplicationTile> {
  bool hovered = false;

  static const _stages = ["Applied", "Review", "Interview", "Offer"];

  @override
  Widget build(BuildContext context) {
    final status = widget.data.status;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        transform: Matrix4.identity()..translate(0.0, hovered ? -3.0 : 0.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: hovered
                      ? AppColors.tileFillHover
                      : AppColors.tileFillBase,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hovered
                        ? status.color.withValues(alpha: 0.45)
                        : AppColors.cardBorder,
                  ),
                  boxShadow: hovered
                      ? [
                          BoxShadow(
                            color: status.color.withValues(alpha: 0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    // Left accent bar
                    Container(
                      width: 4,
                      height: 78,
                      decoration: BoxDecoration(
                        color: status.color,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildAvatar(status),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.data.role,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.textPrimary,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.building_2_fill,
                                            size: 11,
                                            color: AppColors.textFaded40,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.data.company,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textFaded55,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            CupertinoIcons.time,
                                            size: 11,
                                            color: AppColors.textFaded40,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.data.appliedOn,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textFaded40,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildStatusBadge(status),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildStageProgress(status),
                            const SizedBox(height: 14),
                            //                             Align(
                            //                               alignment: Alignment.bottomRight,
                            //                             child:OfferEmailButton(data: widget.data,
                            //  alreadySent: widget.alreadySent,   // NEW
                            //   onSent: widget.onOfferSent,
                            //                             ),
                            //                             ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ApplicationStatus status) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: kAccentGradient),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentMid.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        widget.data.companyInitial,
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ApplicationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: GoogleFonts.poppins(
              color: status.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageProgress(ApplicationStatus status) {
    final isRejected = status == ApplicationStatus.rejected;
    final activeIndex = status.stageIndex;

    return Row(
      children: List.generate(_stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stageBefore = i ~/ 2;
          final filled =
              stageBefore < activeIndex ||
              (stageBefore == activeIndex && !isRejected);
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: filled
                  ? status.color.withValues(alpha: isRejected ? 0.3 : 0.6)
                  : AppColors.cardBorder,
            ),
          );
        }
        final stageIdx = i ~/ 2;
        // final isDone = stageIdx < activeIndex;
        final isCurrent = stageIdx == activeIndex;
        final isFuture = stageIdx > activeIndex;

        Color dotColor;
        if (isFuture) {
          dotColor = AppColors.glassBorder;
        } else if (isCurrent && isRejected) {
          dotColor = status.color;
        } else {
          dotColor = status.color;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCurrent ? 10 : 7,
              height: isCurrent ? 10 : 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: status.color.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ApplicationsGlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  const _ApplicationsGlassContainer({
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.all(20),
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
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
