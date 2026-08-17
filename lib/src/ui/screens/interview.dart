import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/ui/screens/camera.dart';
import 'package:landpage/src/ui/widgets/calendar.dart';
import 'package:landpage/src/ui/widgets/guidelines.dart';
// import 'package:landpage/src/ui/theme/colors.dart';
import 'package:landpage/src/utils/colors.dart'; // adjust path if different

/// Shared accent gradient — keep in sync with dashboard.dart's kAccentGradient.
const List<Color> kInterviewAccentGradient = AppColors.accentGradient;

/// How early a candidate is allowed to join before the scheduled time.
const Duration kJoinWindowBefore = Duration(minutes: 10);

/// How long after the scheduled time the room stays joinable.
const Duration kJoinWindowAfter = Duration(minutes: 60);

enum InterviewStatus { upcoming, completed, cancelled }

enum _JoinState { early, active, over }

class InterviewData {
  final String interviewId;
  final String company;
  final String role;
  final String type;
  final DateTime dateTime;
  final InterviewStatus status;
  final String interviewer;

  const InterviewData({
    required this.interviewId,
    required this.company,
    required this.role,
    required this.type,
    required this.dateTime,
    required this.status,
    required this.interviewer,
  });
}

class InterviewsSection extends StatefulWidget {
  const InterviewsSection({super.key});

  @override
  State<InterviewsSection> createState() => _InterviewsSectionState();
}

class _InterviewsSectionState extends State<InterviewsSection> {
  String _filter = "All";

  final List<InterviewData> _interviews = [
    InterviewData(
      interviewId: "INT_1001",
      company: "Fable Studio",
      role: "Frontend Engineer",
      type: "Technical Round",
      dateTime: DateTime.now(),
      status: InterviewStatus.upcoming,
      interviewer: "Riya Kapoor",
    ),

    InterviewData(
      interviewId: "INT_1004",
      company: "Accenture",
      role: "Frontend Engineer",
      type: "Technical Round",
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      status: InterviewStatus.upcoming,
      interviewer: "Dhyan Kapoor",
    ),

    // InterviewData(
    //   interviewId: "INT_1005",
    //   company: "Orbit Robotics",
    //   role: "Frontend Engineer",
    //   type: "Technical Round",
    //   dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    //   status: InterviewStatus.cancelled,
    //   interviewer: "Dhyan Kapoor",
    // ),
    InterviewData(
      interviewId: "INT_1002",
      company: "Artisan Labs",
      role: "AI Trainer",
      type: "HR Round",
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 5)),
      status: InterviewStatus.cancelled,
      interviewer: "Devon Marsh",
    ),
    InterviewData(
      interviewId: "INT_1003",
      company: "Lumen Health",
      role: "Frontend Engineer",
      type: "Final Round",
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      status: InterviewStatus.completed,
      interviewer: "Amara Osei",
    ),

    // InterviewData(
    //   interviewId: "INT_1004",
    //   company: "Lumen Health",
    //   role: "UX Designer",
    //   type: "Technical Round",
    //   dateTime: DateTime.now().subtract(const Duration(days: 6)),
    //   status: InterviewStatus.cancelled,
    //   interviewer: "Liam Chen",
    // ),
  ];

  List<InterviewData> get _filtered {
    if (_filter == "All") return _interviews;
    final status = InterviewStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == _filter.toLowerCase(),
    );
    return _interviews.where((i) => i.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSummaryRow(),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: _buildInterviewList()),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildPrepCard()),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  _buildInterviewList(),
                  const SizedBox(height: 24),
                  _buildPrepCard(),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Interviews",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Track upcoming, completed and cancelled interviews.",
                style: GoogleFonts.poppins(
                  color: AppColors.textFaded65,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          children: ["All", "Upcoming", "Completed", "Cancelled"]
              .map(
                (f) => _FilterChip(
                  label: f,
                  selected: _filter == f,
                  onTap: () => setState(() => _filter = f),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final upcoming = _interviews
        .where((i) => i.status == InterviewStatus.upcoming)
        .length;
    final completed = _interviews
        .where((i) => i.status == InterviewStatus.completed)
        .length;
    final cancelled = _interviews
        .where((i) => i.status == InterviewStatus.cancelled)
        .length;

    final stats = [
      _SummaryData(
        label: "Upcoming",
        value: "$upcoming",
        icon: CupertinoIcons.calendar_badge_plus,
      ),
      _SummaryData(
        label: "Completed",
        value: "$completed",
        icon: CupertinoIcons.checkmark_seal,
      ),
      _SummaryData(
        label: "Cancelled",
        value: "$cancelled",
        icon: CupertinoIcons.xmark_seal,
      ),
      _SummaryData(
        label: "Total",
        value: "${_interviews.length}",
        icon: CupertinoIcons.square_stack_3d_up,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final crossAxisCount = isWide
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 3.6,
          ),
          itemBuilder: (context, index) => _SummaryCard(data: stats[index]),
        );
      },
    );
  }

  Widget _buildInterviewList() {
    final items = _filtered;
    return _GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Schedule",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  "No interviews in this category.",
                  style: GoogleFonts.poppins(
                    color: AppColors.textFaded50,
                    fontSize: 13.5,
                  ),
                ),
              ),
            )
          else
            ...items.map((i) => _InterviewTile(data: i)),
        ],
      ),
    );
  }

  Widget _buildPrepCard() {
    return _GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interview Prep",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Sharpen up before your next round with tailored resources.",
            style: GoogleFonts.poppins(
              color: AppColors.sectionLabel,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildGradientButton("Start Mock Interview", CupertinoIcons.mic, () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const CameraView(),
            //   ),
            // );
            CameraOverlay.show(context, interviewId: 'mock_practice');
          }),
          const SizedBox(height: 14),
          _buildOutlineButton(
            "Candidate Guidelines",
            CupertinoIcons.doc_text,
            () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const Placeholder(),
              //   ),
              // );
              showGuidelineDialog(context);
            },
          ),
          const SizedBox(height: 14),
          _buildOutlineButton("Add to calendar", CupertinoIcons.calendar, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarScreen(interviews: _interviews),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(colors: kInterviewAccentGradient),
        ),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: AppColors.textPrimary),
          label: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 4,
            backgroundColor: AppColors.glassFillHover,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.textSecondary),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            color: AppColors.textSecondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.outlineBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.5),
          ),
          backgroundColor: AppColors.outlineBg,
        ),
      ),
    );
  }
}

_JoinState _getJoinState(DateTime scheduledAt) {
  final now = DateTime.now();
  final earliest = scheduledAt.subtract(kJoinWindowBefore);
  final latest = scheduledAt.add(kJoinWindowAfter);

  if (now.isBefore(earliest)) return _JoinState.early;
  if (now.isAfter(latest)) return _JoinState.over;
  return _JoinState.active;
}

void _handleJoinTap(BuildContext context, InterviewData data) {
  final state = _getJoinState(data.dateTime);

  switch (state) {
    case _JoinState.early:
      _showJoinInfoDialog(
        context,
        icon: CupertinoIcons.clock,
        iconColor: AppColors.statusUpcomingInterview,
        title: "Interview not started yet",
        message:
            "This interview is scheduled for ${_formatDate(data.dateTime)} at "
            "${_formatTime(data.dateTime)}. You can join up to "
            "${kJoinWindowBefore.inMinutes} minutes early.",
      );
      break;
    case _JoinState.over:
      _showJoinInfoDialog(
        context,
        icon: CupertinoIcons.xmark_seal,
        iconColor: AppColors.statusCancelledInterview,
        title: "This interview has ended",
        message:
            "The scheduled window for this interview closed on "
            "${_formatDate(data.dateTime)} at ${_formatTime(data.dateTime)}. "
            "Please reach out if you believe this is a mistake.",
      );
      break;
    case _JoinState.active:

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Placeholder()),
      // );
      CameraOverlay.show(context, interviewId: data.interviewId);

      break;
  }
}

void _showJoinInfoDialog(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String message,
}) {
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
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconColor.withValues(alpha: 0.15),
                          border: Border.all(
                            color: iconColor.withValues(alpha: 0.4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, color: iconColor, size: 19),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: AppColors.textFaded65,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      // Expanded(
                      //   child: SizedBox(
                      //     height: 42,
                      //     child: OutlinedButton(
                      //       onPressed: () => Navigator.of(dialogContext).pop(),
                      //       style: OutlinedButton.styleFrom(
                      //         side: BorderSide(
                      //           color: Colors.white.withValues(alpha: .18),
                      //         ),
                      //         backgroundColor: Colors.white.withValues(alpha: .04),
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //       ),
                      //       child: Text(
                      //         "Close",
                      //         style: GoogleFonts.poppins(color: Colors.white70),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              gradient: const LinearGradient(
                                colors: kInterviewAccentGradient,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.glassFillHover,
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: Text(
                                "Got it",
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

String _formatDate(DateTime d) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return "${months[d.month - 1]} ${d.day}, ${d.year}";
}

String _formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? "PM" : "AM";
  return "$hour:$minute $period";
}

class _InterviewTile extends StatelessWidget {
  final InterviewData data;
  const _InterviewTile({required this.data});

  bool get _isTappable => data.status == InterviewStatus.upcoming;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(data.dateTime);
    final timeStr = _formatTime(data.dateTime);

    final tile = Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: kInterviewAccentGradient
                    .map((c) => c.withValues(alpha: 0.35))
                    .toList(),
              ),
              border: Border.all(color: AppColors.glassBorder),
            ),
            alignment: Alignment.center,
            child: Text(
              data.company.isNotEmpty ? data.company[0].toUpperCase() : "?",
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${data.role} · ${data.company}",
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusBadge(status: data.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${data.type} · with ${data.interviewer}",
                  style: GoogleFonts.poppins(
                    color: AppColors.textFaded55,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 13,
                      color: AppColors.textFaded50,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        color: AppColors.sectionLabel,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      CupertinoIcons.clock,
                      size: 13,
                      color: AppColors.textFaded50,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: GoogleFonts.poppins(
                        color: AppColors.sectionLabel,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!_isTappable) return tile;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleJoinTap(context, data),
      child: tile,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final InterviewStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    switch (status) {
      case InterviewStatus.upcoming:
        color = AppColors.statusInterview;
        label = "Upcoming";
        break;
      case InterviewStatus.completed:
        color = AppColors.statusCompletedInterview;
        label = "Completed";
        break;
      case InterviewStatus.cancelled:
        color = AppColors.statusCancelledInterview;
        label = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        //colorssssssss
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: selected
              ? const LinearGradient(colors: kInterviewAccentGradient)
              : null,
          color: selected ? null : AppColors.glassFill06,
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SummaryData {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.centerRight,
        children: [
          // Decorative watermark icon — fills the empty right side of the card.
          Positioned(
            right: -12,
            child: Icon(data.icon, size: 72, color: AppColors.inputFill),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: kInterviewAccentGradient
                        .map((c) => c.withValues(alpha: 0.3))
                        .toList(),
                  ),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Icon(data.icon, color: AppColors.textPrimary, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.value,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      data.label,
                      style: GoogleFonts.poppins(
                        color: AppColors.sectionLabel,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  const _GlassContainer({
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassFill07,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
