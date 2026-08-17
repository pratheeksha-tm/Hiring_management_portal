import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:landpage/src/ui/screens/applications_section.dart';
import 'package:landpage/src/ui/screens/settings.dart';
import 'package:landpage/src/ui/screens/company.dart';
import 'package:landpage/src/ui/screens/interview.dart';
import 'package:landpage/src/forms/register.dart';
import 'package:landpage/src/ui/screens/savedroles.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/utils/colors.dart' show AppColors;
import '../../forms/login.dart';

const List<Color> kAccentGradient = AppColors.accentGradient;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthService authService = AuthService();
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  String currentTab = "Overview";

  final LayerLink _profileLayerLink = LayerLink();
  OverlayEntry? _profileOverlayEntry;
  bool _profileMenuOpen = false;
  late final AnimationController _profileMenuController;

  @override
  void initState() {
    super.initState();
    _profileMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _removeProfileOverlay();
    _profileMenuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("⑨ DashboardPage build() called, currentUser=${auth.currentUser}");
    final user = auth.currentUser;
    final displayName = (user?.email ?? "there").split('@').first;

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
                  _buildTopBar(displayName),
                  const SizedBox(height: 32),
                  _buildBody(displayName),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String displayName) {
    switch (currentTab) {
      case "Applications":
        return _buildApplicationsTab();
      case "saved roles":
        return _buildSavedRolesTab();
      case "Settings":
        return _buildSettingsTab(displayName);
      case "Companies":
        return _buildCompaniesTab();
      case "Interview":
        return _buildInterviewTab();
      case "Overview":
      default:
        return _buildOverviewTab(displayName);
    }
  }

  Widget _buildOverviewTab(String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreeting(displayName),
        const SizedBox(height: 32),

        _buildStatsRow(),
        //////this one
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: _buildActivityCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildQuickActionsCard()),
                  ],
                ),
              );
            }
            return Column(
              children: [
                _buildActivityCard(),
                const SizedBox(height: 24),
                _buildQuickActionsCard(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildApplicationsTab() {
    return const ApplicationsSection();
  }

  Widget _buildSavedRolesTab() {
    return SelectedRolesSection();
  }

  Widget _buildSettingsTab(displayName) {
    return SettingsSection(
      displayName: displayName,
      // displayName: "Pratheeksha",
      email: auth.currentUser?.email ?? "",
    );
  }

  Widget _buildInterviewTab() {
    return const InterviewsSection();
  }

  Widget _buildCompaniesTab() {
    return const CompaniesSection();
  }

  Widget _buildTopBar(String displayName) {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Image.asset(
            'images/logo.png',
            height: 30,
            width: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            "ARTISAN",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _NavTextItem(
            title: "Overview",
            selected: currentTab == "Overview",
            onTap: () => setState(() => currentTab = "Overview"),
          ),
          _NavTextItem(
            title: "Companies",
            selected: currentTab == "Companies",
            onTap: () => setState(() => currentTab = "Companies"),
          ),
          _NavTextItem(
            title: "Saved Roles",
            selected: currentTab == "saved roles",
            onTap: () => setState(() => currentTab = "saved roles"),
          ),
          _NavTextItem(
            title: "Applications",
            selected: currentTab == "Applications",
            onTap: () => setState(() => currentTab = "Applications"),
          ),

          _NavTextItem(
            title: "Interviews",
            selected: currentTab == "Interview",
            onTap: () => setState(() => currentTab = "Interview"),
          ),
          _NavTextItem(
            title: "Settings",
            selected: currentTab == "Settings",
            onTap: () => setState(() => currentTab = "Settings"),
          ),
          const SizedBox(width: 20),
          _buildProfileChip(displayName),
        ],
      ),
    );
  }

  Widget _buildProfileChip(String displayName) {
    final user = auth.currentUser;
    final email = user?.email ?? "";

    return CompositedTransformTarget(
      link: _profileLayerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggleProfileMenu(displayName, email),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _profileMenuOpen
                ? AppColors.glassFillHover
                : AppColors.glassFill,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _profileMenuOpen
                  ? AppColors.glassBorderHover
                  : AppColors.glassBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: kAccentGradient),
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
              Text(
                displayName,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 2),
              AnimatedRotation(
                turns: _profileMenuOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleProfileMenu(String displayName, String email) {
    if (_profileMenuOpen) {
      _closeProfileMenu();
    } else {
      _openProfileMenu(displayName, email);
    }
  }

  void _openProfileMenu(String displayName, String email) {
    _removeProfileOverlay();

    _profileOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Full-screen transparent barrier — tap outside to close.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeProfileMenu,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _profileLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 10),
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              child: Align(
                alignment: Alignment.topRight,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _profileMenuController,
                    curve: Curves.easeOut,
                  ),
                  child: ScaleTransition(
                    alignment: Alignment.topRight,
                    scale: CurvedAnimation(
                      parent: _profileMenuController,
                      curve: Curves.easeOutBack,
                      reverseCurve: Curves.easeIn,
                    ),
                    child: _ProfileDropdownMenu(
                      displayName: displayName,
                      email: email,
                      onLogout: () async {
                        _profileMenuController.stop();
                        _removeProfileOverlay();
                        if (mounted) {
                          setState(() => _profileMenuOpen = false);
                        }

                        await authService.logoutUser(
                          context: context,
                          registerPage: const RegisterApp(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_profileOverlayEntry!);
    setState(() => _profileMenuOpen = true);
    _profileMenuController.forward(from: 0);
  }

  void _closeProfileMenu() async {
    if (!_profileMenuOpen) return;
    await _profileMenuController.reverse();
    _removeProfileOverlay();
    if (mounted) setState(() => _profileMenuOpen = false);
  }

  void _removeProfileOverlay() {
    _profileOverlayEntry?.remove();
    _profileOverlayEntry = null;
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
          "Here's what's happening with your workspace today.",
          style: GoogleFonts.poppins(color: AppColors.chipLabel, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      _StatData(
        label: "Applications Successfully Submitted to the team",
        value: "7",
        icon: CupertinoIcons.paperplane_fill,
        delta: "+2 this week",
      ),
      _StatData(
        label: "Upcoming Interviews Scheduled This Week",
        value: "3",
        icon: CupertinoIcons.calendar,
        delta: "Next: Tomorrow",
      ),
      _StatData(
        label: "Overall Recruiter Profile Views and Visits",
        value: "142",
        icon: CupertinoIcons.eye,
        delta: "+23 this week",
      ),
      _StatData(
        label: "Bookmarked Career Opportunities for Future Applications",
        value: "15",
        icon: CupertinoIcons.bookmark,
        delta: "3 closing soon",
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
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) => _StatCard(data: stats[index]),
        );
      },
    );
  }

  Widget _buildActivityCard() {
    final activities = [
      _ActivityData(
        title: "Application viewed by Frontend team",
        time: "2h ago",
        icon: Icons.visibility_outlined,
      ),
      _ActivityData(
        title: "Interview confirmed: Senior Frontend Engineer",
        time: "5h ago",
        icon: Icons.event_available_outlined,
      ),
      _ActivityData(
        title: "New role matches your profile: Frontend Engineer",
        time: "1d ago",
        icon: Icons.auto_awesome_outlined,
      ),
      _ActivityData(
        title: "Application submitted: Frontend Engineer",
        time: "2d ago",
        icon: Icons.send_outlined,
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

  Widget _buildQuickActionsCard() {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildGradientButton("Browse Open Roles", CupertinoIcons.plus, () {
            setState(() {
              currentTab = "Companies";
            });
          }),
          const SizedBox(height: 14),
          _buildOutlineButton("My Profile", CupertinoIcons.person_add, () {
            setState(() {
              currentTab = "Settings";
            });
          }),
          const SizedBox(height: 14),
          _buildOutlineButton("Account Settings", CupertinoIcons.settings, () {
            setState(() {
              currentTab = "Settings";
            });
          }),
          const SizedBox(height: 28),
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
          gradient: const LinearGradient(colors: kAccentGradient),
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
            backgroundColor: AppColors.glassBorder,
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

class _ProfileDropdownMenu extends StatelessWidget {
  final String displayName;
  final String email;
  final VoidCallback onLogout;

  const _ProfileDropdownMenu({
    required this.displayName,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 240,
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowPurple.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: avatar + name + email
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: kAccentGradient),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : "?",
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: AppColors.textFaded55,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 1, color: AppColors.cardBorder),

                const SizedBox(height: 6),

                _DropdownMenuTile(
                  icon: CupertinoIcons.square_arrow_right,
                  label: "Log out",
                  onTap: onLogout,
                  destructive: true,
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _DropdownMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  State<_DropdownMenuTile> createState() => _DropdownMenuTileState();
}

class _DropdownMenuTileState extends State<_DropdownMenuTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.destructive
        ? AppColors.logoutTextColor
        : AppColors.textEmphasis90;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        // behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: hovered ? AppColors.glassFill : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            //to make the logout center
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: fg),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: fg,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTextItem extends StatefulWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  const _NavTextItem({required this.title, this.selected = false, this.onTap});

  @override
  State<_NavTextItem> createState() => _NavTextItemState();
}

class _NavTextItemState extends State<_NavTextItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = isHovered || widget.selected;
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
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 1.5,
                width: active ? 28 : 0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: kAccentGradient),
                ),
              ),
            ],
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
                          style: GoogleFonts.poppins(
                            color: AppColors.textFaded65,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data.delta,
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
