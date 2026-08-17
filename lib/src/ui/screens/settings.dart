import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/forms/register.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/ui/widgets/settingpopup.dart';
import 'package:landpage/src/services/settingservice.dart';
// import 'package:landpage/src/ui/theme/colors.dart';
import 'package:landpage/src/utils/colors.dart';

class SettingsSection extends StatefulWidget {
  final String displayName;
  final String email;

  const SettingsSection({
    super.key,
    required this.displayName,
    required this.email,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

enum _ProfileVisibility { public, recruitersOnly, hidden }

enum _SettingsTab { profile, account }

class _SettingsSectionState extends State<SettingsSection> {
  _SettingsTab _tab = _SettingsTab.profile;
  final SettingsService _settingsService = SettingsService();

  late final TextEditingController _nameController = TextEditingController(
    text: widget.displayName,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "••••••••••",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        final sidebar = _SettingsSidebar(
          selected: _tab,
          onSelect: (t) => setState(() => _tab = t),
        );

        final content = GlassContainer(
          radius: 20,
          padding: const EdgeInsets.all(28),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _tab == _SettingsTab.profile
                ? _ProfilePane(
                    key: const ValueKey("profile"),
                    displayName: widget.displayName,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    settingsService: _settingsService,
                  )
                : _AccountPane(
                    key: const ValueKey("account"),
                    settingsService: _settingsService,
                  ),
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 240, child: sidebar),
              const SizedBox(width: 24),
              Expanded(child: content),
            ],
          );
        }

        return Column(children: [sidebar, const SizedBox(height: 24), content]);
      },
    );
  }
}

class _SettingsSidebar extends StatelessWidget {
  final _SettingsTab selected;
  final ValueChanged<_SettingsTab> onSelect;

  const _SettingsSidebar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              "Settings",
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SidebarTile(
            icon: CupertinoIcons.person_crop_circle,
            label: "Profile",
            selected: selected == _SettingsTab.profile,
            onTap: () => onSelect(_SettingsTab.profile),
          ),
          _SidebarTile(
            icon: CupertinoIcons.gear_alt,
            label: "Account",
            selected: selected == _SettingsTab.account,
            onTap: () => onSelect(_SettingsTab.account),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.selected
                ? LinearGradient(
                    colors: AppColors.accentGradient
                        .map((c) => c.withValues(alpha: 0.28))
                        .toList(),
                  )
                : null,
            color: !widget.selected && hovered ? AppColors.glassFill06 : null,
            border: widget.selected
                ? Border.all(color: AppColors.outlineBorder)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: active ? AppColors.textPrimary : AppColors.sectionLabel,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.sectionLabel,
                  fontSize: 13.5,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePane extends StatelessWidget {
  final String displayName;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final SettingsService settingsService;

  const _ProfilePane({
    super.key,
    required this.displayName,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "General Profile",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Update your profile picture and account information.",
          style: GoogleFonts.poppins(
            color: AppColors.sectionLabel,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 28),
        Builder(
          builder: (context) {
            final isWide = MediaQuery.sizeOf(context).width > 900;
            final avatar = _AvatarPicker(displayName: displayName);

            final fields = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsField(
                  label: "Display name",
                  controller: nameController,
                ),
                const SizedBox(height: 14),
                _SettingsField(
                  label: "Email",
                  controller: emailController,
                  trailing: "UPDATE",
                  onTrailingTap: () {
                    showGlassFieldDialog(
                      context: context,
                      title: "Update Email",
                      description:
                          "Enter your current password and new email address.",
                      hintText: "New email",
                      icon: CupertinoIcons.mail_solid,
                      initialValue: emailController.text,
                      confirmLabel: "Update",
                      requireCurrentPassword: true,
                      onConfirm: (newEmail, currentPassword) {
                        settingsService.updateEmail(
                          context: context,
                          currentPassword: currentPassword,
                          newEmail: newEmail,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                _SettingsField(
                  label: "Password",
                  controller: passwordController,
                  obscure: true,
                  trailing: "UPDATE",
                  onTrailingTap: () {
                    showGlassFieldDialog(
                      context: context,
                      title: "Update Password",
                      description:
                          "Enter your current password and a new password.",
                      hintText: "New password",
                      icon: CupertinoIcons.lock_fill,
                      obscureText: true,
                      confirmLabel: "Update",
                      requireCurrentPassword: true,
                      onConfirm: (newPassword, currentPassword) {
                        settingsService.updatePassword(
                          context: context,
                          currentPassword: currentPassword,
                          newPassword: newPassword,
                        );
                      },
                    );
                  },
                ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: fields,
                  ),
                ],
              );
            }
            return Column(
              children: [
                avatar,
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: fields,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Divider(color: AppColors.cardBorder, height: 1),
        const SizedBox(height: 28),
        const _ResumeField(),
        const SizedBox(height: 28),
        Divider(color: AppColors.cardBorder, height: 1),
        const SizedBox(height: 28),
        const _SkillsetPicker(),
      ],
    );
  }
}

class _AvatarPicker extends StatefulWidget {
  final String displayName;

  const _AvatarPicker({required this.displayName});

  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  Uint8List? _avatarBytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _avatarBytes == null
                ? AppColors.accentLinearGradient
                : null,
            border: Border.all(color: AppColors.outlineBorder),
          ),
          alignment: Alignment.center,
          child: _avatarBytes != null
              ? ClipOval(
                  child: Image.memory(
                    _avatarBytes!,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                )
              // : Text(
              //     widget.displayName.isNotEmpty
              //         ? widget.displayName[0].toUpperCase()
              //         : "?",
              //     style: GoogleFonts.poppins(
              //       color: AppColors.textPrimary,
              //       fontSize: 30,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'icons/profile.svg',
                    width: 65,
                    height: 65,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            showAvatarUploadDialog(
              context: context,
              currentImageBytes: _avatarBytes,
              onConfirm: (bytes) {
                setState(() => _avatarBytes = bytes);
                // TODO: authService.updateAvatar(context: context, imageBytes: bytes);
              },
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "UPDATE",
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResumeField extends StatefulWidget {
  const _ResumeField();

  @override
  State<_ResumeField> createState() => _ResumeFieldState();
}

class _ResumeFieldState extends State<_ResumeField> {
  String? fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Resume",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Upload your resume so recruiters can review it with your applications.",
          style: GoogleFonts.poppins(
            color: AppColors.textFaded55,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardGradientStart),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: AppColors.accentGradient
                        .map((c) => c.withValues(alpha: 0.35))
                        .toList(),
                  ),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Icon(
                  CupertinoIcons.doc_text_fill,
                  color: AppColors.textPrimary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? "No resume uploaded",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: fileName != null
                            ? AppColors.textPrimary
                            : AppColors.textFaded45,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fileName != null
                          ? "PDF · Uploaded"
                          : "PDF, DOC up to 5MB",
                      style: GoogleFonts.poppins(
                        color: AppColors.textFaded40,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  showResumeUploadDialog(
                    context: context,
                    currentFileName: fileName,
                    onConfirm: (file) {
                      setState(() => fileName = file.name);
                    },
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  fileName != null ? "UPDATE" : "UPLOAD",
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkillsetPicker extends StatefulWidget {
  const _SkillsetPicker();

  @override
  State<_SkillsetPicker> createState() => _SkillsetPickerState();
}

class _SkillsetPickerState extends State<_SkillsetPicker> {
  final List<String> allSkills = const [
    "Flutter",
    "React",
    "Node.js",
    "Python",
    "C",
    "C++",
    "C#",
    "JavaScript",
    "Django",
    "Angular",
    "Vue",
    "UI/UX Design",
    "SQL",
    "MongoDB",
    "Product Management",
    "Data Analysis",
    "Cloud (AWS/GCP)",
  ];

  final Set<String> selected = {"Flutter", "UI/UX Design"};
  bool _applied = false;

  void _toggle(String skill) {
    setState(() {
      if (selected.contains(skill)) {
        selected.remove(skill);
      } else {
        selected.add(skill);
      }
      _applied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Skillset",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Pick the skills you'd like recruiters to match you on.",
          style: GoogleFonts.poppins(
            color: AppColors.textFaded55,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allSkills.map((skill) {
            final isSelected = selected.contains(skill);
            return GestureDetector(
              onTap: () => _toggle(skill),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: isSelected ? AppColors.accentLinearGradient : null,
                  color: isSelected ? null : AppColors.inputFill,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 42,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: AppColors.accentLinearGradient,
            ),
            child: ElevatedButton(
              onPressed: _applied
                  ? null
                  : () {
                      setState(() => _applied = true);
                      // TODO: persist `selected` skills (Firestore, API, etc.)
                    },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.glassBorder,
                disabledBackgroundColor: AppColors.glassBorder,
                foregroundColor: AppColors.textPrimary,
                disabledForegroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_applied) ...[
                    const Icon(
                      CupertinoIcons.check_mark,
                      size: 15,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _applied ? "Applied" : "Apply",
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileVisibilityPicker extends StatefulWidget {
  const _ProfileVisibilityPicker();

  @override
  State<_ProfileVisibilityPicker> createState() =>
      _ProfileVisibilityPickerState();
}

class _ProfileVisibilityPickerState extends State<_ProfileVisibilityPicker> {
  _ProfileVisibility _selected = _ProfileVisibility.recruitersOnly;

  static const Map<
    _ProfileVisibility,
    ({String label, String desc, IconData icon})
  >
  _options = {
    _ProfileVisibility.public: (
      label: "Public",
      desc: "Anyone can view your profile.",
      icon: CupertinoIcons.globe,
    ),
    _ProfileVisibility.recruitersOnly: (
      label: "Recruiters",
      desc: "Only verified recruiters can view your profile.",
      icon: CupertinoIcons.briefcase_fill,
    ),
    _ProfileVisibility.hidden: (
      label: "Hidden",
      desc: "Your profile won't appear in search or matches.",
      icon: CupertinoIcons.eye_slash_fill,
    ),
  };

  void _select(_ProfileVisibility v) {
    setState(() => _selected = v);
    // TODO: persist visibility (Firestore, API, etc.)
    // settingsService.updateProfileVisibility(context: context, visibility: v);
  }

  @override
  Widget build(BuildContext context) {
    final current = _options[_selected]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Profile visibility",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            current.desc,
            key: ValueKey(_selected),
            style: GoogleFonts.poppins(
              color: AppColors.textFaded55,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: _options.entries.map((entry) {
              final isSelected = _selected == entry.key;
              final opt = entry.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _select(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: isSelected
                          ? AppColors.accentLinearGradient
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.accentGradient.first
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          opt.icon,
                          size: 18,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.sectionLabel,
                        ),
                        // const SizedBox(height: 2),
                        Text(
                          opt.label,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.sectionLabel,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const _SettingsField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textFaded50,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardGradientStart),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (trailing != null)
                TextButton(
                  onPressed: onTrailingTap,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    trailing!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountPane extends StatelessWidget {
  final SettingsService settingsService;

  const _AccountPane({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Account",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          "Manage your account status and data.",
          style: GoogleFonts.poppins(
            color: AppColors.sectionLabel,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        Divider(color: AppColors.cardBorder, height: 1),
        const SizedBox(height: 24),
        const _ProfileVisibilityPicker(),
        const SizedBox(height: 14),
        Divider(color: AppColors.cardBorder, height: 1),
        const SizedBox(height: 14),
        _AccountRow(
          icon: CupertinoIcons.square_arrow_right,
          title: "Log out of all devices",
          subtitle: "Sign out from all devices and clear your session.",
          actionLabel: "Log out",
          destructive: true,
          onTap: () {
            showLogoutDialog(
              context: context,
              registerPage: const RegisterApp(),
            );
          },
        ),
        const SizedBox(height: 14),
        Divider(color: AppColors.cardBorder, height: 1),
        const SizedBox(height: 14),
        _AccountRow(
          icon: CupertinoIcons.trash,
          title: "Delete account",
          subtitle: "Permanently delete your account and all associated data.",
          actionLabel: "Delete",
          destructive: true,
          onTap: () {
            showGlassFieldDialog(
              context: context,
              title: "Delete Account",
              description:
                  "This permanently deletes your account and all data. Enter your password to confirm.",
              hintText: "Current password",
              icon: CupertinoIcons.lock_fill,
              obscureText: true,
              confirmLabel: "Delete",
              requireCurrentPassword: false,
              onConfirm: (password, _) {
                settingsService.deleteAccount(
                  context: context,
                  currentPassword: password,
                  registerPage:
                      const RegisterApp(), // <-- REPLACE with your real register/login widget
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final bool destructive;

  const _AccountRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = destructive
        ? AppColors.statusCancelledInterview
        : AppColors.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: destructive
                ? AppColors.statusCancelledInterview.withValues(alpha: 0.12)
                : AppColors.glassFill,
            border: Border.all(
              color: destructive
                  ? AppColors.statusCancelledInterview.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
            ),
          ),
          child: Icon(icon, size: 17, color: accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: AppColors.textFaded50,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: destructive
                  ? AppColors.statusCancelledInterview.withValues(alpha: 0.4)
                  : AppColors.outlineBorder,
            ),
            backgroundColor: destructive
                ? AppColors.statusCancelledInterview.withValues(alpha: 0.08)
                : AppColors.outlineBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(
            actionLabel,
            style: GoogleFonts.poppins(
              color: accent,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
