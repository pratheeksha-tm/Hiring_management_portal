// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landpage/dashboard.dart
import 'package:landpage/main.dart'; // for LandingPage (Home)
import 'package:landpage/src/forms/register.dart';
import 'package:landpage/src/ui/screens/aboutUs.dart';
import 'package:landpage/src/ui/screens/contactUs.dart';
import 'package:landpage/src/ui/screens/openroles.dart';
import 'package:landpage/src/ui/screens/opentalents.dart';
import 'package:landpage/src/utils/colors.dart';

class CustomAppBar extends StatelessWidget {
  final bool isContactPage;
  final bool isAboutPage;
  const CustomAppBar({
    super.key,
    this.isContactPage = false,
    this.isAboutPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                style: GoogleFonts.syne(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NavTextItem(
                title: "Talents",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Placeholder()),
                  );
                },
              ),

              NavTextItem(
                title: "Companies",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OpenRolesPage()),
                  );
                },
              ),

              // NavTextItem(
              //   title: "About Us",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => const Placeholder()),
              //     );
              //   },
              // ),
              NavTextItem(
                title: isAboutPage ? "Home" : "About Us",
                onTap: () {
                  if (isAboutPage) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LandingPage()),
                      (route) => false,
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsPage()),
                    );
                  }
                },
              ),

              const SizedBox(width: 390),

              Row(
                children: [
                  NavTextItem(
                    title: isContactPage ? "Home" : "Contact Us",
                    onTap: () {
                      if (isContactPage) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LandingPage(),
                          ),
                          (route) => false,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ContactUsPage(),
                          ),
                        );
                      }
                    },
                  ),

                  // NavTextItem(
                  //   title: "Login",
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => const Placeholder(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(width: 13),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterApp()),
                      );

                      // final user = FirebaseAuth.instance.currentUser;

                      //   if (user != null) {
                      //     await user.reload(); // refresh session, in case it's stale
                      //   }

                      //   final freshUser = FirebaseAuth.instance.currentUser;

                      //   if (freshUser != null && freshUser.emailVerified) {
                      //     // Already logged in and verified -> go straight to Dashboard
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const DashboardPage()),
                      //     );
                      //   } else {
                      //     // Not logged in -> show login/register screen
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const RegisterApp()),
                      //     );
                      //   }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            "Login ",
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavTextItem extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const NavTextItem({super.key, required this.title, this.onTap});

  @override
  State<NavTextItem> createState() => _NavTextItemState();
}

class _NavTextItemState extends State<NavTextItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 1.5,
                width: isHovered ? 35 : 0,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
