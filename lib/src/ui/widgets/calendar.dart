import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';

import 'package:landpage/src/ui/screens/interview.dart';
// import 'package:landpage/src/ui/theme/colors.dart'; // adjust path if different

const List<Color> kAccentGradient = AppColors.accentGradient;

class CalendarEvent {
  final String title;
  final String description;
  final TimeOfDay? time;
  final bool isInterview;
  final InterviewStatus? interviewStatus;

  CalendarEvent({
    required this.title,
    this.description = "",
    this.time,
    this.isInterview = false,
    this.interviewStatus,
  });
}

class CalendarScreen extends StatefulWidget {
  final List<InterviewData> interviews;

  const CalendarScreen({super.key, this.interviews = const []});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // key = normalized (y, m, d) date — manually added events only.
  final Map<DateTime, List<CalendarEvent>> _events = {};

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, List<CalendarEvent>> get _interviewEvents {
    final map = <DateTime, List<CalendarEvent>>{};
    for (final i in widget.interviews) {
      final key = _normalize(i.dateTime);
      map
          .putIfAbsent(key, () => [])
          .add(
            CalendarEvent(
              title: "${i.company} Interview",
              description: "${i.role} · ${i.type} with ${i.interviewer}",
              time: TimeOfDay.fromDateTime(i.dateTime),
              isInterview: true,
              interviewStatus: i.status,
            ),
          );
    }
    return map;
  }

  // Manual events + auto interview events, merged, for a given day.
  List<CalendarEvent> _eventsForDay(DateTime day) {
    final key = _normalize(day);
    return [...(_interviewEvents[key] ?? []), ...(_events[key] ?? [])];
  }

  void _addEvent(DateTime day, CalendarEvent event) {
    final key = _normalize(day);
    setState(() {
      _events.putIfAbsent(key, () => []).add(event);
    });
  }

  void _removeEvent(DateTime day, CalendarEvent event) {
    final key = _normalize(day);
    setState(() {
      _events[key]?.remove(event);
    });
  }

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay? pickedTime;

    await showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.removeButtonBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentMid.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: kAccentGradient,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  CupertinoIcons.calendar_badge_plus,
                                  color: AppColors.textPrimary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "New Event",
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                            style: GoogleFonts.poppins(
                              color: AppColors.textFaded55,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDialogTextField(
                            controller: titleController,
                            hint: "Event title",
                            icon: CupertinoIcons.text_cursor,
                          ),
                          const SizedBox(height: 14),
                          _buildDialogTextField(
                            controller: descController,
                            hint: "Description (optional)",
                            icon: CupertinoIcons.doc_text,
                            minLines: 1,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: AppColors.accentMid,
                                        surface: AppColors.datePickerSurface,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setDialogState(() => pickedTime = time);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.glassFill06,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.clock,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    pickedTime == null
                                        ? "Pick a time"
                                        : pickedTime!.format(context),
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: AppColors.outlineBorder,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: kAccentGradient,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (titleController.text.trim().isEmpty) {
                                        return;
                                      }
                                      _addEvent(
                                        _selectedDay,
                                        CalendarEvent(
                                          title: titleController.text.trim(),
                                          description: descController.text
                                              .trim(),
                                          time: pickedTime,
                                        ),
                                      );
                                      Navigator.pop(dialogContext);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Add Event",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textPrimary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int minLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassFill06,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 13.5,
        ),
        cursorColor: AppColors.accentLight,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Icon(icon, color: AppColors.textFaded55, size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textMuted,
            fontSize: 13.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _eventsForDay(_selectedDay);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('images/land1.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 32),
                  _buildCalendarCard(),
                  const SizedBox(height: 24),
                  _buildEventsCard(selectedEvents),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: kAccentGradient),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentMid.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddEventDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(CupertinoIcons.add, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: kAccentGradient),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.calendar,
              color: AppColors.textPrimary,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "My Calendar",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        // eventLoader now returns manual + auto-generated interview events,
        // so interview dates show a marker dot without any manual entry.
        eventLoader: _eventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: const Icon(
            CupertinoIcons.chevron_left,
            color: AppColors.textSecondary,
            size: 18,
          ),
          rightChevronIcon: const Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.textSecondary,
            size: 18,
          ),
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.poppins(
            color: AppColors.textFaded50,
            fontSize: 12,
          ),
          weekendStyle: GoogleFonts.poppins(
            color: AppColors.textFaded50,
            fontSize: 12,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          weekendTextStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentLight, width: 1.5),
          ),
          todayTextStyle: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          selectedDecoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: kAccentGradient),
          ),
          selectedTextStyle: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          markerDecoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentLight,
          ),
          markersMaxCount: 3,
          markerSize: 5,
          markerMargin: const EdgeInsets.only(top: 4),
        ),
      ),
    );
  }

  Widget _buildEventsCard(List<CalendarEvent> events) {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Events on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${events.length}",
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "No events for this day yet.",
                style: GoogleFonts.poppins(
                  color: AppColors.textFaded50,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...events.map((e) => _buildEventTile(e)),
        ],
      ),
    );
  }

  Color _statusColor(InterviewStatus? status) {
    switch (status) {
      case InterviewStatus.upcoming:
        return AppColors.statusInterview;
      case InterviewStatus.completed:
        return AppColors.statusCompletedInterview;
      case InterviewStatus.cancelled:
        return AppColors.statusCancelledInterview;
      case null:
        return AppColors.accentLight;
    }
  }

  Widget _buildEventTile(CalendarEvent event) {
    final accent = event.isInterview
        ? _statusColor(event.interviewStatus)
        : AppColors.accentLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: event.isInterview
              ? accent.withValues(alpha: 0.35)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: event.isInterview ? accent : null,
              gradient: event.isInterview
                  ? null
                  : const LinearGradient(
                      colors: kAccentGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (event.isInterview)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          event.interviewStatus?.name ?? "Interview",
                          style: GoogleFonts.poppins(
                            color: accent,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: GoogleFonts.poppins(
                      color: AppColors.sectionLabel,
                      fontSize: 12.5,
                    ),
                  ),
                ],
                if (event.time != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(CupertinoIcons.clock, color: accent, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        event.time!.format(context),
                        style: GoogleFonts.poppins(
                          color: accent,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Interview events are auto-generated and can't be deleted here —
          // only manually-added events show the remove icon.
          if (!event.isInterview)
            GestureDetector(
              onTap: () => _removeEvent(_selectedDay, event),
              child: const Icon(
                CupertinoIcons.xmark_circle,
                color: AppColors.textMuted,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
