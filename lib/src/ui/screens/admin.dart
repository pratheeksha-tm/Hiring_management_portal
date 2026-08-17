import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:landpage/src/forms/login.dart';
import 'package:landpage/src/forms/register.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/utils/colors.dart' show AppColors;

const List<Color> kAccentGradient = AppColors.accentGradient;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthService authService = AuthService();
  String currentTab = "Dashboard";

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final displayName = (user?.email ?? "there").split('@').first;
    final email = user?.email ?? "";

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('images/land1.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Sidebar(
                    currentTab: currentTab,
                    displayName: displayName,
                    email: email,
                    onSelect: (t) {
                      if (t == "Logout") {
                        authService.logoutUser(
                          context: context,
                          registerPage: const RegisterApp(),
                        );
                      } else {
                        setState(() => currentTab = t);
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(child: _buildRightSection(displayName)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection(String displayName) {
    switch (currentTab) {
      case "Dashboard":
        return _buildOverviewTab(displayName);
      // Other tabs
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab(String displayName) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(displayName),
          const SizedBox(height: 32),
          _buildStatsRow(),
          const SizedBox(height: 32),
          _buildActivityCard(),
        ],
      ),
    );
  }

  Widget _buildGreeting(String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Welcome, $displayName ",
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              "icons/wave.svg",
              width: 30,
              height: 30,
              color: AppColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Here's an overview of your platform activity today.",
          style: GoogleFonts.poppins(color: AppColors.chipLabel, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      _StatData(
        label: "Total Posts Published on the Platform",
        value: "24",
        icon: CupertinoIcons.checkmark_seal,
        delta: "+3 this week",
      ),
      _StatData(
        label: "Applications Awaiting Review",
        value: "18",
        icon: CupertinoIcons.person_2,
        delta: "+5 this week",
      ),
      _StatData(
        label: "Interviews Scheduled This Week",
        value: "6",
        icon: CupertinoIcons.chart_bar_alt_fill,
        delta: "Next: Tomorrow",
      ),
      _StatData(
        label: "Settings Changes Pending Approval",
        value: "2",
        icon: CupertinoIcons.gear_alt,
        delta: "1 closing soon",
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
            childAspectRatio: 1.9,
          ),
          itemBuilder: (context, index) => _StatCard(data: stats[index]),
        );
      },
    );
  }

  Widget _buildActivityCard() {
    final activities = [
      _ActivityData(
        title: "New post published: Backend Engineer role",
        time: "2h ago",
        icon: Icons.article_outlined,
      ),
      _ActivityData(
        title: "Application received for Frontend Engineer",
        time: "5h ago",
        icon: Icons.person_add_alt_outlined,
      ),
      _ActivityData(
        title: "Interview scheduled with a shortlisted candidate",
        time: "1d ago",
        icon: Icons.event_available_outlined,
      ),
      _ActivityData(
        title: "Settings updated by admin",
        time: "2d ago",
        icon: Icons.settings_outlined,
      ),
    ];

    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...activities.map((a) => _buildActivityTile(a)),
        ],
      ),
    );
  }

  Widget _buildActivityTile(_ActivityData a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: kAccentGradient
                    .map((c) => c.withValues(alpha: 0.35))
                    .toList(),
              ),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(a.icon, color: AppColors.textPrimary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              a.title,
              style: GoogleFonts.poppins(
                color: AppColors.textEmphasis90,
                fontSize: 13.5,
              ),
            ),
          ),
          Text(
            a.time,
            style: GoogleFonts.poppins(
              color: AppColors.textFaded50,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentTab;
  final String displayName;
  final String email;
  final ValueChanged<String> onSelect;

  const _Sidebar({
    required this.currentTab,
    required this.displayName,
    required this.email,
    required this.onSelect,
  });

  static const _mainItems = [
    _SidebarItemData("Dashboard", CupertinoIcons.square_grid_2x2_fill),
    _SidebarItemData("Posts", CupertinoIcons.checkmark_seal),
    _SidebarItemData("Applications", CupertinoIcons.person_2),
    _SidebarItemData("Interview", CupertinoIcons.chart_bar_alt_fill),
    // _SidebarItemData("Plans & Payments", CupertinoIcons.creditcard),
    // _SidebarItemData("Notifications", CupertinoIcons.bell),
  ];

  static const _bottomItems = [
    _SidebarItemData("Settings", CupertinoIcons.gear_alt),
    _SidebarItemData("Logout", CupertinoIcons.arrow_right_square),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: GlassContainer(
        radius: 24,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogo(),
            const SizedBox(height: 32),
            ..._mainItems.map(
              (item) => _SidebarNavTile(
                data: item,
                selected: currentTab == item.label,
                onTap: () => onSelect(item.label),
              ),
            ),
            const Spacer(),
            ..._bottomItems.map(
              (item) => _SidebarNavTile(
                data: item,
                selected: currentTab == item.label,
                onTap: () => onSelect(item.label),
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
            const SizedBox(height: 12),
            _buildProfile(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(colors: kAccentGradient),
          ),
          child: const Icon(
            CupertinoIcons.cube_box_fill,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "ARTISAN",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: kAccentGradient),
            ),
            alignment: Alignment.center,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.textFaded55,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          // Icon(
          //   CupertinoIcons.chevron_up_chevron_down,
          //   color: AppColors.textSecondary,
          //   size: 14,
          // ),
        ],
      ),
    );
  }
}

class _SidebarItemData {
  final String label;
  final IconData icon;
  const _SidebarItemData(this.label, this.icon);
}

class _SidebarNavTile extends StatefulWidget {
  final _SidebarItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<_SidebarNavTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    final fg = active
        ? AppColors.textPrimary
        : (hovered ? AppColors.textEmphasis90 : AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: active
                  ? const LinearGradient(colors: kAccentGradient)
                  : null,
              color: active
                  ? null
                  : (hovered ? AppColors.glassFillHover : Colors.transparent),
              border: active
                  ? null
                  : Border.all(
                      color: hovered
                          ? AppColors.glassBorderHover
                          : Colors.transparent,
                    ),
            ),
            child: Row(
              children: [
                Icon(widget.data.icon, size: 18, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.data.label,
                    style: GoogleFonts.poppins(
                      color: fg,
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.delta,
  });
}

class _StatCard extends StatefulWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..translate(0.0, hovered ? -4.0 : 0.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: hovered
                    ? AppColors.cardGradientStart
                    : AppColors.glassFill,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hovered
                      ? AppColors.cardBorderHover
                      : AppColors.glassBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: kAccentGradient),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.value,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.data.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.textFaded65,
                            fontSize: 12.5,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data.delta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.accentLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
}

class _ActivityData {
  final String title;
  final String time;
  final IconData icon;
  _ActivityData({required this.title, required this.time, required this.icon});
}
