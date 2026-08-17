import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/models/saved.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/ui/custom/toast.dart';
import 'package:landpage/src/utils/colors.dart' show AppColors;
import 'dashboard.dart' show kAccentGradient;

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

class SelectedRolesSection extends StatefulWidget {
  const SelectedRolesSection({super.key});

  @override
  State<SelectedRolesSection> createState() => _SelectedRolesSectionState();
}

class _SelectedRolesSectionState extends State<SelectedRolesSection> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";
  String _filter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SelectedRole> get _roles {
    return SavedRoles.roles;
  }

  @override
  Widget build(BuildContext context) {
    final roles = _roles.where((item) {
      final matchesSearch =
          item.role.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.company.name.toLowerCase().contains(_query.toLowerCase());

      final matchesFilter = _filter == "All" || item.role.type == _filter;

      return matchesSearch && matchesFilter;
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Selected Roles",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Manage all the opportunities you've shortlisted.",
          style: GoogleFonts.poppins(
            color: AppColors.textFaded65,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        _buildStats(),
        const SizedBox(height: 28),
        _buildSearchBar(),
        const SizedBox(height: 18),
        _buildFilters(),
        const SizedBox(height: 24),
        if (roles.isEmpty)
          _buildEmptyState()
        else
          buildColumnMasonry<SelectedRole>(
            roles,
            (item) {
              return _SelectedRoleCard(
                data: item,
                isApplied: SavedRoles.appliedRoles.contains(item.key),
                onApply: () {
                  SavedRoles.appliedRoles.add(item.key);

                  setState(() {});

                  showSnackBar(
                    context,
                    "Application sent for ${item.role.title} at ${item.company.name}",
                  );
                },
                onRemove: () {
                  SavedRoles.roles.remove(item);
                  setState(() {});

                  showSnackBar(
                    context,
                    "${item.role.title} removed from saved roles",
                    color: Colors.redAccent,
                  );
                },
              );
            },
            columnCount: 4,
            rowGap: 14,
          ),
      ],
    );
  }

  Widget _buildStats() {
    final roles = _roles;
    final total = roles.length;
    final fullTime = roles.where((e) => e.role.type == "Full-time").length;
    final remote = roles.where((e) => e.role.location == "Remote").length;
    final internshipCount = roles
        .where((r) => r.role.type == "Internship")
        .length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 2.4,
          children: [
            _RoleStatCard(
              icon: CupertinoIcons.bookmark_fill,
              title: "Selected Roles",
              value: "${roles.length}",
              subtitle: "Total saved",
            ),
            _RoleStatCard(
              icon: CupertinoIcons.checkmark_circle_fill,
              title: "Internships",
              value: "$internshipCount",
              percentage: total == 0 ? 0 : internshipCount / total,
            ),
            _RoleStatCard(
              icon: CupertinoIcons.location_solid,
              title: "Remote Roles",
              value: "$remote",
              percentage: total == 0 ? 0 : remote / total,
            ),
            _RoleStatCard(
              icon: CupertinoIcons.briefcase_fill,
              title: "Full-time",
              value: "$fullTime",
              percentage: total == 0 ? 0 : fullTime / total,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return GlassContainer(
      radius: 16,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: _searchController,
          onChanged: (v) {
            setState(() {
              _query = v;
            });
          },
          style: GoogleFonts.poppins(color: AppColors.textPrimary),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: AppColors.textFaded45,
            ),
            hintText: "Search selected roles...",
            hintStyle: GoogleFonts.poppins(color: AppColors.textFaded40),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = "");
                    },
                    icon: Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: AppColors.textFaded45,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ["All", "Full-time", "Internship"];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = filters[index];

          final selected = item == _filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _filter = item;
              });
            },
            child: GlassContainer(
              radius: 30,
              padding: EdgeInsets.zero,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(colors: kAccentGradient)
                      : null,
                  color: selected ? null : AppColors.glassFill07,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  item,
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
    );
  }

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.glassFill06,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardGradientStart),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: kAccentGradient),
                ),
                child: Icon(
                  CupertinoIcons.bookmark_fill,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "No Selected Roles",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Browse companies and shortlist\nroles you like.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.sectionLabel,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedRoleCard extends StatefulWidget {
  final SelectedRole data;
  final bool isApplied;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  const _SelectedRoleCard({
    // super.key,
    required this.data,
    required this.isApplied,
    required this.onApply,
    required this.onRemove,
  });

  @override
  State<_SelectedRoleCard> createState() => _SelectedRoleCardState();
}

class _SelectedRoleCardState extends State<_SelectedRoleCard> {
  bool expanded = false;
  final ScrollController _descScrollController = ScrollController();

  @override
  void dispose() {
    _descScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.data.role;
    final company = widget.data.company;

    // Same fixed-ratio card as the company roles grid — the outer size
    // never changes on expand; the description scrolls internally instead.
    return AspectRatio(
      aspectRatio: 1.2,
      child: GlassContainer(
        radius: 18,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: kAccentGradient),
                  ),
                  child: Icon(company.icon, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        company.name,
                        style: GoogleFonts.poppins(
                          color: AppColors.sectionLabel,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.bookmark_fill,
                    color: AppColors.accentLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
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

            const SizedBox(height: 16),

            // Fixed-height description area (fills remaining card space,
            // same role the old fixed content used to play). Collapsed it
            // clips to 2 lines like before; expanded it scrolls internally
            // instead of growing the card.
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: expanded
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
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              role.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppColors.textFaded65,
                                fontSize: 12.5,
                                height: 1.45,
                              ),
                            ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          expanded ? "Show less" : "Read more",
                          style: GoogleFonts.poppins(
                            color: AppColors.accentLight,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        Icon(
                          expanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          size: 12,
                          color: AppColors.accentLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: widget.onRemove,

                      icon: Icon(
                        CupertinoIcons.delete,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),

                      label: Text(
                        "Remove",
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.removeButtonBorder),
                        backgroundColor: AppColors.outlineBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 42,
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
                        onPressed: widget.isApplied ? null : widget.onApply,

                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.glassFillHover,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),

                        child: Text(
                          widget.isApplied ? "Applied ✓" : "Apply",
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
        // ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.glassFill06,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardGradientStart),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.sectionLabel),

          const SizedBox(width: 5),

          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.chipLabel,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final double? percentage;

  const _RoleStatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 18,
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: kAccentGradient),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppColors.sectionLabel,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (percentage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage!.clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.glassFill,
                valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${(percentage! * 100).toStringAsFixed(0)}% of total",
              style: GoogleFonts.poppins(
                color: AppColors.textFaded50,
                fontSize: 11,
              ),
            ),
          ] else if (subtitle != null)
            Text(
              subtitle!,
              style: GoogleFonts.poppins(
                color: AppColors.textFaded50,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
