// import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/models/saved.dart';
import 'package:landpage/src/ui/custom/toast.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/ui/widgets/guestuserpopup.dart';

// import 'package:landpage/src/ui/custom/toast.dart';
import 'dashboard.dart' show kAccentGradient;
import 'package:landpage/src/utils/colors.dart' show AppColors;

class RoleData {
  final String title;
  final String location;
  final String type; // e.g. Full-time, Remote
  final String salary;
  final String description;
  const RoleData({
    required this.title,
    required this.location,
    required this.type,
    required this.salary,
    required this.description,
  });
}

class CompanyData {
  final String name;
  final String tagline;
  final IconData icon;
  final List<RoleData> roles;
  const CompanyData({
    required this.name,
    required this.tagline,
    required this.icon,
    required this.roles,
  });
}

final List<CompanyData> kCompanies = [
  CompanyData(
    name: "Nova Analytics",
    tagline:
        "Data platforms for modern enterprises, Where data becomes decisions",
    icon: CupertinoIcons.chart_bar_alt_fill,
    roles: const [
      RoleData(
        title: "Senior ML Engineer",
        location: "Remote",
        type: "Full-time",
        salary: "\$140k – \$170k",
        description:
            "Own the modeling pipeline for our forecasting product, from feature engineering to production deployment. You'll work closely with data engineering to scale training jobs and with product to translate business questions into models.",
      ),
      RoleData(
        title: "Data Platform Engineer",
        location: "Bengaluru, IN",
        type: "Full-time",
        salary: "\$95k – \$120k",
        description:
            "Build and maintain the ingestion and warehousing systems that power every dashboard our customers see. You'll design schemas, optimize query performance, and keep pipelines reliable at scale. Experience with distributed data systems is a plus.",
      ),
      RoleData(
        title: "Analytics Intern",
        location: "Remote",
        type: "Internship",
        salary: "\$2k/mo",
        description:
            "A 3-month internship supporting the analytics team with reporting, ad-hoc  SQL analysis, and dashboard upkeep. Great fit for a student or recent grad looking to get hands-on experience with real production data.",
      ),
    ],
  ),
  CompanyData(
    name: "Orbit Robotics",
    tagline: "Autonomous systems for logistics, Smarter operations start here.",
    icon: CupertinoIcons.gear_alt_fill,
    roles: const [
      RoleData(
        title: "Robotics Software Engineer",
        location: "San Francisco, CA",
        type: "Full-time",
        salary: "\$150k – \$185k",
        description:
            "Design and ship the navigation and perception stack for our warehouse robots. You'll work in C++ and ROS, collaborate with hardware engineers, and validate systems on the floor. Strong background in robotics or controls required.",
      ),
      RoleData(
        title: "Embedded Systems Engineer",
        location: "Hybrid",
        type: "Full-time",
        salary: "\$120k – \$150k",
        description:
            "Own firmware for our sensor and motor-control boards. You'll bring up new hardware revisions, write low-level drivers, and debug issues that span firmware and hardware. Experience with real-time embedded systems expected.",
      ),
      RoleData(
        title: "frontend Engineer",
        location: "Hybrid",
        type: "Full-time",
        salary: "\$120k – \$150k",
        description:
            "Build responsive and user-friendly web interfaces using modern frontend technologies. You'll collaborate with designers and backend engineers to develop high-quality features, optimize application performance.",
      ),
    ],
  ),
  CompanyData(
    name: "Lumen Health",
    tagline: "Advancing healthcare with AI, AI-assisted diagnostics",
    icon: CupertinoIcons.heart_fill,
    roles: const [
      RoleData(
        title: "Product Designer",
        location: "Remote",
        type: "Full-time",
        salary: "\$100k – \$130k",
        description:
            "Shape the end-to-end experience of our clinician-facing diagnostic tools. You'll run research sessions with practicing doctors, prototype in Figma, and partner with engineering to ship polished, accessible interfaces.",
      ),
      RoleData(
        title: "Clinical Data Analyst",
        location: "Boston, MA",
        type: "Internship",
        salary: "\$60/hr",
        description:
            "Analyze de-identified clinical datasets to support model validation studies. You'll work with our data science team to build reporting and flag data quality issues. Background in health data or biostatistics preferred.",
      ),
      RoleData(
        title: "AI Trainer",
        location: "Remote",
        type: "Full-time",
        salary: "\$45/hr",
        description:
            "Review and label model outputs for accuracy and safety in a clinical context. Flexible full-time hours, fully remote. A clinical or life-sciences background is helpful but not required.",
      ),
      RoleData(
        title: "Frontend Engineer",
        location: "Remote",
        type: "Full-time",
        salary: "\$45/hr",
        description:
            "Build responsive and user-friendly web interfaces using modern frontend technologies. You'll collaborate with designers and backend engineers to develop high-quality features, optimize application performance, and deliver seamless user experiences across devices. Experience with React, JavaScript/TypeScript, HTML, and CSS is preferred.",
      ),
    ],
  ),
  CompanyData(
    name: "Fable Studio",
    tagline:
        "Every story deserves great tools, Creative tools for storytellers",
    icon: CupertinoIcons.paintbrush_fill,
    roles: const [
      RoleData(
        title: "Frontend Engineer",
        location: "Remote",
        type: "Full-time",
        salary: "\$110k – \$140k",
        description:
            "Build the editor experience creators use every day — a canvas-heavy, performance-sensitive web app. You'll work in React and TypeScript alongside designers to ship features end to end.",
      ),
      RoleData(
        title: "UX Researcher",
        location: "New York, NY",
        type: "Full-time",
        salary: "\$105k – \$125k",
        description:
            "Lead qualitative and quantitative research to guide our product roadmap. You'll run interviews with working writers and illustrators, synthesize findings, and present actionable recommendations to design and product leadership.",
      ),
    ],
  ),
];

Widget buildColumnMasonry<T>(
  List<T> items,
  Widget Function(T item) builder, {
  int columnCount = 3,
  double columnGap = 12,
  double rowGap = 12,
}) {
  final columns = List.generate(columnCount, (_) => <Widget>[]);

  for (int i = 0; i < items.length; i++) {
    final columnIndex = i % columnCount;
    final isLastInColumn = i >= items.length - columnCount;
    final card = Padding(
      padding: EdgeInsets.only(bottom: isLastInColumn ? 0 : rowGap),
      child: builder(items[i]),
    );
    columns[columnIndex].add(card);
  }

  final rowChildren = <Widget>[];
  for (int c = 0; c < columnCount; c++) {
    if (c > 0) rowChildren.add(SizedBox(width: columnGap));
    rowChildren.add(
      Expanded(
        child: Column(mainAxisSize: MainAxisSize.min, children: columns[c]),
      ),
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rowChildren,
  );
}

class CompaniesSection extends StatefulWidget {
  final bool guestMode;
  const CompaniesSection({super.key, this.guestMode = false});

  @override
  State<CompaniesSection> createState() => _CompaniesSectionState();
}

class _CompaniesSectionState extends State<CompaniesSection> {
  final Set<String> _savedRoles = {}; // keyed by "Company::RoleTitle"
  // final Set<String> _appliedRoles = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSaved(CompanyData company, RoleData role) {
    final key = "${company.name}::${role.title}";

    setState(() {
      if (_savedRoles.contains(key)) {
        _savedRoles.remove(key);

        SavedRoles.roles.removeWhere(
          (e) => e.company.name == company.name && e.role.title == role.title,
        );
      } else {
        _savedRoles.add(key);

        SavedRoles.roles.add(SelectedRole(company: company, role: role));
      }
    });
  }

  void _markApplied(String key) {
    setState(() {
      SavedRoles.appliedRoles.add(key);
    });
  }

  List<CompanyData> get _filteredCompanies {
    Iterable<CompanyData> list = kCompanies;

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) {
        final matchesCompany =
            c.name.toLowerCase().contains(q) ||
            c.tagline.toLowerCase().contains(q);
        final matchesRole = c.roles.any(
          (r) =>
              r.title.toLowerCase().contains(q) ||
              r.location.toLowerCase().contains(q) ||
              r.type.toLowerCase().contains(q),
        );
        return matchesCompany || matchesRole;
      });
    }

    return list.toList();
  }

  void _openRoles(CompanyData company) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CompanyRolesPage(
            company: company,
            savedRoles: _savedRoles,
            appliedRoles: SavedRoles.appliedRoles,
            onToggleSaved: _toggleSaved,
            onApply: _markApplied,
            guestMode: widget.guestMode,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companies = _filteredCompanies;
    final totalRoles = kCompanies.fold<int>(
      0,
      (sum, c) => sum + c.roles.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Companies",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "$totalRoles open roles across ${kCompanies.length} companies.",
          style: GoogleFonts.poppins(
            color: AppColors.textFaded65,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 20),
        GlassContainer(
          radius: 14,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: "Search companies, roles, or locations…",
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textFaded40,
                  fontSize: 13.5,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: AppColors.textFaded45,
                  size: 19,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          CupertinoIcons.clear_circled_solid,
                          color: AppColors.textFaded45,
                          size: 18,
                        ),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _query = "";
                        }),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (companies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.search,
                    color: AppColors.cardBorderHover,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No companies match \"$_query\"",
                    style: GoogleFonts.poppins(
                      color: AppColors.textFaded50,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          buildColumnMasonry<CompanyData>(companies, (company) {
            final savedInCompany = company.roles
                .where(
                  (r) => _savedRoles.contains("${company.name}::${r.title}"),
                )
                .length;
            return _CompanyListTile(
              company: company,
              savedCount: savedInCompany,
              onTap: () => _openRoles(company),
            );
          }, columnCount: 4),
      ],
    );
  }
}

class _CompanyListTile extends StatefulWidget {
  final CompanyData company;
  final int savedCount;
  final VoidCallback onTap;
  const _CompanyListTile({
    required this.company,
    required this.savedCount,
    required this.onTap,
  });

  @override
  State<_CompanyListTile> createState() => _CompanyListTileState();
}

class _CompanyListTileState extends State<_CompanyListTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,

        child: AspectRatio(
          aspectRatio: 1.6,
          // aspectratio:2
          child: GlassContainer(
            radius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'company-icon-${company.name}',
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: kAccentGradient,
                          ),
                        ),
                        child: Icon(
                          company.icon,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (widget.savedCount > 0)
                      Icon(
                        CupertinoIcons.bookmark_fill,
                        size: 13,
                        color: AppColors.accentLight.withOpacity(0.85),
                      ),
                  ],
                ),
                const SizedBox(height: 25),
                Hero(
                  tag: 'company-name-${company.name}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      company.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  company.tagline,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.textFaded55,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),

                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        "${company.roles.length} role${company.roles.length == 1 ? '' : 's'}",
                        style: GoogleFonts.poppins(
                          color: AppColors.accentLight,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColors.textFaded40,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompanyRolesPage extends StatefulWidget {
  final CompanyData company;
  final Set<String> savedRoles;
  final Set<String> appliedRoles;
  // final void Function(String key) onToggleSaved;
  final void Function(CompanyData, RoleData) onToggleSaved;
  final void Function(String key) onApply;
  final bool guestMode;

  const CompanyRolesPage({
    super.key,
    required this.company,
    required this.savedRoles,
    required this.appliedRoles,
    required this.onToggleSaved,
    required this.onApply,
    this.guestMode = false,
  });

  @override
  State<CompanyRolesPage> createState() => _CompanyRolesPageState();
}

class _CompanyRolesPageState extends State<CompanyRolesPage> {
  String _typeFilter = "All";
  final TextEditingController _roleSearchController = TextEditingController();
  String _roleQuery = "";

  @override
  void dispose() {
    _roleSearchController.dispose();
    super.dispose();
  }

  List<String> get _types {
    final set = <String>{"All"};
    for (final r in widget.company.roles) {
      set.add(r.type);
    }
    return set.toList();
  }

  List<RoleData> get _filteredRoles {
    Iterable<RoleData> roles = widget.company.roles;

    if (_typeFilter != "All") {
      roles = roles.where((r) => r.type == _typeFilter);
    }

    final q = _roleQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      roles = roles.where(
        (r) =>
            r.title.toLowerCase().contains(q) ||
            r.location.toLowerCase().contains(q) ||
            r.type.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q),
      );
    }

    return roles.toList();
  }

  void _showApplyConfirmation(RoleData role) {
    widget.onApply("${widget.company.name}::${role.title}");
    showSnackBar(
      context,
      "Application sent for ${role.title} at ${widget.company.name}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final roles = _filteredRoles;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('images/land1.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            CupertinoIcons.back,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  sliver: SliverToBoxAdapter(
                    child: GlassContainer(
                      radius: 20,

                      padding: const EdgeInsets.all(18),

                      child: Row(
                        children: [
                          Hero(
                            tag: 'company-icon-${company.name}',
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: kAccentGradient,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowPurpleDeep
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                company.icon,
                                color: AppColors.textPrimary,
                                size: 25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: 'company-name-${company.name}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      company.name,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  company.tagline,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.sectionLabel,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  sliver: SliverToBoxAdapter(
                    child: GlassContainer(
                      radius: 14,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        height: 46,
                        child: TextField(
                          controller: _roleSearchController,
                          onChanged: (v) => setState(() => _roleQuery = v),
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: "Search roles at ${company.name}…",
                            hintStyle: GoogleFonts.poppins(
                              color: AppColors.textFaded40,
                              fontSize: 13.5,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                              color: AppColors.textFaded45,
                              size: 19,
                            ),
                            suffixIcon: _roleQuery.isEmpty
                                ? null
                                : IconButton(
                                    icon: Icon(
                                      CupertinoIcons.clear_circled_solid,
                                      color: AppColors.textFaded45,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() {
                                      _roleSearchController.clear();
                                      _roleQuery = "";
                                    }),
                                  ),
                          ),
                        ),
                        // ),
                      ),
                    ),
                  ),
                ),
                //filterchips
                SliverPadding(
                  padding: const EdgeInsets.only(left: 24, bottom: 16),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _types.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final type = _types[index];
                          final selected = type == _typeFilter;
                          return GestureDetector(
                            onTap: () => setState(() => _typeFilter = type),
                            child: GlassContainer(
                              radius: 20,
                              padding: EdgeInsets.zero,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? const LinearGradient(
                                          colors: kAccentGradient,
                                        )
                                      : null,
                                  color: selected
                                      ? null
                                      : AppColors.glassFill07,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.transparent
                                        : AppColors.glassFillHover,
                                  ),
                                ),
                                child: Text(
                                  type,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (roles.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              color: AppColors.cardBorderHover,
                              size: 30,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No roles match \"$_roleQuery\"",
                              style: GoogleFonts.poppins(
                                color: AppColors.textFaded50,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverToBoxAdapter(
                      child: buildColumnMasonry<RoleData>(
                        roles,
                        (role) {
                          final key = "${company.name}::${role.title}";
                          return _RoleTile(
                            role: role,
                            isSaved: widget.savedRoles.contains(key),
                            isApplied: widget.appliedRoles.contains(key),
                            onSave: () => setState(
                              () => widget.onToggleSaved(company, role),
                            ),
                            onApply: () =>
                                setState(() => _showApplyConfirmation(role)),
                            guestMode: widget.guestMode,
                          );
                        },
                        columnCount: 4,
                        rowGap: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatefulWidget {
  final RoleData role;
  final bool isSaved;
  final bool isApplied;
  final VoidCallback onSave;
  final VoidCallback onApply;
  final bool guestMode;

  const _RoleTile({
    required this.role,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onApply,
    this.guestMode = false,
  });

  @override
  State<_RoleTile> createState() => _RoleTileState();
}

class _RoleTileState extends State<_RoleTile> {
  bool _expanded = false;
  final ScrollController _descScrollController = ScrollController();

  @override
  void dispose() {
    _descScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    return AspectRatio(
      aspectRatio: 1.2,
      child: GlassContainer(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    role.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.isApplied) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      "Applied",
                      style: GoogleFonts.poppins(
                        color: AppColors.success,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 25),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _RoleChip(
                  icon: CupertinoIcons.location_solid,
                  label: role.location,
                ),
                _RoleChip(
                  icon: CupertinoIcons.briefcase_fill,
                  label: role.type,
                ),
                _RoleChip(
                  icon: CupertinoIcons.money_dollar,
                  label: role.salary,
                ),
              ],
            ),
            const SizedBox(height: 25),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _expanded = !_expanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _expanded
                          ? Scrollbar(
                              controller: _descScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _descScrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Text(
                                  role.description,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textFaded65,
                                    fontSize: 12.5,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              role.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppColors.textFaded65,
                                fontSize: 12.5,
                                height: 1.6,
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expanded ? "Show less" : "Read more",
                          style: GoogleFonts.poppins(
                            color: AppColors.accentLight,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          _expanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          size: 10,
                          color: AppColors.accentLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      // onPressed: widget.onSave,
                      onPressed: () {
                        if (widget.guestMode) {
                          showGuestSignInDialog(context);
                          return;
                        }
                        widget.onSave();
                      },
                      icon: Icon(
                        widget.isSaved
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        size: 14,
                        color: widget.isSaved
                            ? AppColors.accentLight
                            : AppColors.textSecondary,
                      ),
                      label: Text(
                        widget.isSaved ? "Saved" : "Save",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: widget.isSaved
                              ? AppColors.accentLight
                              : AppColors.textSecondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: widget.isSaved
                              ? AppColors.accentLight.withOpacity(0.6)
                              : AppColors.outlineBorder,
                        ),
                        backgroundColor: AppColors.outlineBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: widget.isApplied
                            ? null
                            : const LinearGradient(colors: kAccentGradient),
                        color: widget.isApplied ? AppColors.appliedBg : null,
                      ),
                      child: ElevatedButton(
                        // onPressed: widget.isApplied ? null : widget.onApply,
                        onPressed: widget.isApplied
                            ? null
                            : () {
                                if (widget.guestMode) {
                                  showGuestSignInDialog(context);
                                  return;
                                }
                                widget.onApply();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          disabledBackgroundColor: Colors.transparent,
                          backgroundColor: AppColors.glassBorder,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.5),
                          ),
                        ),
                        child: Text(
                          widget.isApplied ? "Applied ✓" : "Apply",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.isApplied
                                ? AppColors.sectionLabel
                                : AppColors.textPrimary,
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
    );
  }
}

class _RoleChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RoleChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.glassFill06,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardGradientStart),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.sectionLabel),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.chipLabel,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
