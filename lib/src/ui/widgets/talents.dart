import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class TalentsSection extends StatelessWidget {
  const TalentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final talents = [
      _TalentData(
        name: "Jessy Houle",
        role: "CEO",
        tagline:
            "Creative problem solver skilled in design, marketing strategy and event execution.",
        image: "images/a1.png",
        current: "UI Designer at Clevertalents",
        experience: "9 years",
        location: "Portland, Oregon, United States",
        looking: "Full-time",
        about:
            "Portland-based graphic designer and creative problem solver passionate about building sustainable brands and businesses. I want to help you build the business of your dreams.",
        skills: "Photoshop CC, UI, Visual Design, Web, UX Design, Sketch",
      ),
      _TalentData(
        name: "Maria Chen",
        role: "CTO",
        tagline:
            "Detail-oriented designer focused on clean systems and scalable design.",
        image: "images/a2.png",
        current: "Product Designer at Northline",
        experience: "6 years",
        location: "Austin, Texas, United States",
        looking: "Full-time",
        about:
            "I specialize in taking early-stage ideas and turning them into polished, usable products. Big believer in design systems and clear documentation.",
        skills: "Figma, Design Systems, Prototyping, User Research",
      ),
      _TalentData(
        name: "Aiden Cross",
        role: "CFO",
        tagline:
            "Passionate about branding, typography, and building memorable visual identities.",
        image: "images/a3.png",
        current: "Freelance Visual Designer",
        experience: "5 years",
        location: "Seattle, Washington, United States",
        looking: "Full-time",
        about:
            "I help startups define their visual identity from the ground up — logos, brand guidelines, and marketing assets that actually get used.",
        skills: "Branding, Illustrator, Typography, Adobe CC",
      ),
      _TalentData(
        name: "Leo Martins",
        role: "CMO",
        tagline:
            "Data-driven researcher helping teams build products people actually want.",
        image: "images/a4.png",
        current: "UX Researcher at Formwave",
        experience: "7 years",
        location: "Denver, Colorado, United States",
        looking: "Full-time",
        about:
            "I run qualitative and quantitative research to validate product decisions before a single line of code is written. Strong believer in testing early and often.",
        skills: "User Research, A/B Testing, Analytics, Interviews",
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Talents",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),

        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: talents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) => _TalentCard(data: talents[index]),
        ),
      ],
    );
  }
}

class _TalentData {
  final String name;
  final String role;
  final String tagline;
  final String image;
  final String current;
  final String experience;
  final String location;
  final String looking;
  final String about;
  final String skills;

  _TalentData({
    required this.name,
    required this.role,
    required this.tagline,
    required this.image,
    required this.current,
    required this.experience,
    required this.location,
    required this.looking,
    required this.about,
    required this.skills,
  });
}

Future<void> _launchSocialUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

class _TalentCard extends StatelessWidget {
  final _TalentData data;

  const _TalentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  data.image,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          data.name,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.role,
                          style: GoogleFonts.poppins(
                            color: AppColors.textFaded55,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.tagline,
                      style: GoogleFonts.poppins(
                        color: AppColors.sectionLabel,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _launchSocialUrl('https://twitter.com'),
                          child: SvgPicture.asset(
                            'assets/icons/twitter.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              AppColors.textFaded45,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: () => _launchSocialUrl('https://facebook.com'),
                          child: SvgPicture.asset(
                            'assets/icons/facebook.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              AppColors.textFaded45,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: () =>
                              _launchSocialUrl('https://instagram.com'),
                          child: SvgPicture.asset(
                            'assets/icons/instagram.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              AppColors.textFaded45,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardGradientStart),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoBlock(label: "Current", value: data.current),
                ),
                Expanded(
                  child: _InfoBlock(
                    label: "Experience",
                    value: data.experience,
                  ),
                ),
                Expanded(
                  child: _InfoBlock(label: "Location", value: data.location),
                ),
                Expanded(
                  child: _InfoBlock(label: "Availability", value: data.looking),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              final about = Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About",
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.about,
                      style: GoogleFonts.poppins(
                        color: AppColors.textFaded65,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );

              final skills = Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Skills",
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.skills,
                      style: GoogleFonts.poppins(
                        color: AppColors.textFaded65,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [about, const SizedBox(width: 32), skills],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [about, const SizedBox(height: 16), skills],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textFaded50,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
