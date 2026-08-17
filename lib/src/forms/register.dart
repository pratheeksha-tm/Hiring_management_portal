import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:landpage/src/ui/screens/dashboard.dart';
import 'package:landpage/src/utils/colors.dart';
import 'package:landpage/src/ui/widgets/forgotpopup.dart';
import 'package:landpage/src/ui/custom/toast.dart';
import '../ui/custom/globe.dart';
import 'package:landpage/src/ui/custom/animated.dart';
import 'login.dart';
import 'package:landpage/src/ui/widgets/passwordrulespopup.dart';

class RegisterApp extends StatefulWidget {
  const RegisterApp({super.key});

  @override
  State<RegisterApp> createState() => _RegisterAppState();
}

class _RegisterAppState extends State<RegisterApp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  final AuthService authService = AuthService();
  // Toggle flag: true => show Login form, false => show Register form
  bool isLogin = true;
  static bool _googleSignInInitialized = false;
  // final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // debugPrint("⑦ RegisterApp initState — WE ARE HERE");
    initializeGoogleSignIn();
  }

  Future<void> initializeGoogleSignIn() async {
    try {
      await googleSignIn.initialize(
        clientId:
            '1067334725424-rsnakp7apt78i4c0dk01cg37ph19vd6t.apps.googleusercontent.com',
      );
      _googleSignInInitialized = true;
    } catch (e) {
      // debugPrint("GoogleSignIn init error: $e");

      _googleSignInInitialized = true;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  List<String> getFailedPasswordRules(String password) {
    final failed = <String>[];

    if (password.length < 8) {
      failed.add("At least 8 characters long");
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      failed.add("At least one uppercase letter (A-Z)");
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      failed.add("At least one lowercase letter (a-z)");
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      failed.add("At least one number (0-9)");
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      failed.add("At least one special character (!@#\$%^&*...)");
    }

    return failed;
  }

  Future<void> _createUserDocument(User user, {String? provider}) async {
    try {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? (user.email?.split('@').first ?? ''),
        'emailVerified': user.emailVerified,
        'provider': provider ?? 'password',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Don't block registration/login flow if this fails — just log it.
      debugPrint("Failed to create user document: $e");
    }
  }

  Future<void> registerUser() async {
    if (emailController.text.trim().isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Please enter your email."),
      //     backgroundColor: Color.fromARGB(255, 154, 102, 163),
      //   ),
      // );
      showSnackBar(context, "Please enter your email.");
      return;
    }
    if (!emailController.text.contains('@')) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Please enter a valid email."),
      //     backgroundColor: Color.fromARGB(255, 154, 102, 163),
      //   ),
      // );
      showSnackBar(context, "Please enter a valid email.");
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Please enter your password."),
      //     backgroundColor:  Color.fromARGB(255, 154, 102, 163),
      //   ),
      // );
      showSnackBar(context, "Please enter your password.");
      return;
    }

    final failedRules = getFailedPasswordRules(passwordController.text.trim());
    if (failedRules.isNotEmpty) {
      showPasswordRulesDialog(context, failedRules: failedRules);
      return;
    }

    try {
      // print("Register button pressed");

      UserCredential user = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Create the Firestore user document right after the auth account exists.
      if (user.user != null) {
        await _createUserDocument(user.user!, provider: 'password');
      }

      await user.user?.sendEmailVerification();
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Registration Successful!Please check your email to verify your account."),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      showSnackBar(
        context,
        "Registration Successful!Please check your email to verify your account..",
      );

      await Future.delayed(const Duration(seconds: 5));

      if (!mounted) return;

      emailController.clear();
      passwordController.clear();

      setState(() {
        isLogin = true; // Show the login form
      });

      // // print(user.user?.uid);
      // print(user.user?.email);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered.";
          break;

        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;

        case 'weak-password':
          message = "Password should be at least 6 characters.";
          break;

        case 'network-request-failed':
          message = "Please check your internet connection.";
          break;

        case 'too-many-requests':
          message = "Too many attempts. Please try again later.";
          break;

        default:
          message = e.message ?? "Registration failed.";
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      showSnackBar(context, message);
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Unexpected Error: $e"),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      showSnackBar(context, "Unexpected Error: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      UserCredential credential = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );

      // Create/update the Firestore user document for Google sign-in too.
      if (credential.user != null) {
        await _createUserDocument(credential.user!, provider: 'google');
      }

      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Google Sign-In Successful"),
      //   ),
      // );
      showSnackBar(context, "Google Sign-In Successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(e.message ?? "Google Sign-In Failed"),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      showSnackBar(context, e.message ?? "Google Sign-In Failed");
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Unexpected Error: $e"),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      showSnackBar(context, "Unexpected Error: $e");
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("⑧ RegisterApp build() called");
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('images/land1.png', fit: BoxFit.cover),
          ),

          //  const AnimatedGlobe(),

          // Globe orbits BEHIND the text — same rough center point.
          Positioned(
            right: 60,
            top: 100,
            child: AnimatedGlobe(
              globeSize: 200,
              orbitRadius: 60,
              duration: const Duration(seconds: 10),
            ),
          ),

          // // Text painted AFTER globe => always on top, globe passes behind it.
          // Positioned(
          //   right: 30,
          //   top: 180,
          //   child: const AnimatedBrandText(),
          // ),
          Positioned(right: 30, top: 180, child: const AnimatedBrandText()),

          //form
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 80),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.glassBorder),
                    ),

                    child: isLogin ? buildLoginForm() : buildRegisterForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRegisterForm() {
    return Column(
      key: const ValueKey('registerForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Create Account",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "Join us and start your journey.",
          style: TextStyle(color: Colors.white.withValues(alpha: .7)),
        ),

        const SizedBox(height: 35),

        // buildField(
        //   controller: nameController,
        //   hint: "Full Name",
        //   icon: Icons.person_outline,
        // ),

        // const SizedBox(height: 18),
        buildField(
          controller: emailController,
          hint: "Email",
          icon: CupertinoIcons.mail_solid,
        ),

        const SizedBox(height: 18),

        buildField(
          controller: passwordController,
          hint: "Password",
          icon: CupertinoIcons.lock_shield,
          obscure: true,
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(colors: AppColors.accentGradient),
            ),
            child: ElevatedButton(
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: AppColors.glassBorder,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5),
                ),
              ),
              child: Text(
                "Sign Up",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),
        Text(
          "--------- or ---------",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
            // fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(colors: AppColors.accentGradient),
            ),
            child: ElevatedButton.icon(
              onPressed: signInWithGoogle,
              icon: SvgPicture.asset(
                "icons/google.svg",
                width: 22,
                height: 22,
                color: AppColors.textPrimary,
              ),
              label: Text(
                "Sign in with Google",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.glassBorder,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(colors: AppColors.accentGradient),
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: SvgPicture.asset(
                "icons/apple.svg",
                width: 22,
                height: 22,
                color: AppColors.textPrimary,
              ),
              label: Text(
                "Sign in with Apple",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.glassBorder,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        TextButton(
          onPressed: () {
            setState(() {
              isLogin = true;
            });
          },
          child: const Text(
            "Already have an account? Login",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget buildLoginForm() {
    return Column(
      key: const ValueKey('loginForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Welcome Back",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "Login to continue your journey.",
          style: TextStyle(color: Colors.white.withValues(alpha: .7)),
        ),

        const SizedBox(height: 35),

        buildField(
          controller: loginEmailController,
          hint: "Email",
          icon: CupertinoIcons.mail_solid,
        ),

        const SizedBox(height: 18),

        buildField(
          controller: loginPasswordController,
          hint: "Password",
          icon: CupertinoIcons.lock_shield,
          obscure: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            //               onPressed: (){
            //                 authService.resetPassword(
            //   context: context,
            //   emailController: loginEmailController,
            // );
            //               },
            onPressed: () {
              showForgotPasswordDialog(
                context,
                initialEmail: loginEmailController.text,
              );
            },
            child: Text(
              "Forgot password?",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                // fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: Container(
            padding: const EdgeInsets.all(1.5), // Border thickness
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(colors: AppColors.accentGradient),
            ),
            child: ElevatedButton(
              onPressed: () {
                authService.loginUser(
                  context: context,
                  loginEmailController: loginEmailController,
                  loginPasswordController: loginPasswordController,
                  dashboardPage: DashboardPage(),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: AppColors.glassBorder,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5),
                ),
              ),
              child: Text(
                "Sign In",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),
        Text(
          "--------- or ---------",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
            // fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: Container(
            padding: const EdgeInsets.all(1.5), // Border thickness
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(colors: AppColors.accentGradient),
            ),
            child: ElevatedButton.icon(
              onPressed: signInWithGoogle,
              icon: SvgPicture.asset(
                "icons/google.svg",
                width: 22,
                height: 22,
                color: AppColors.textPrimary,
              ),
              label: Text(
                "Sign in with Google",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.glassBorder,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: Container(
            padding: const EdgeInsets.all(1.5), // Border thickness
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(colors: AppColors.accentGradient),
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: SvgPicture.asset(
                "icons/apple.svg",
                width: 22,
                height: 22,
                color: AppColors.textPrimary,
              ),
              label: Text(
                "Sign in with Apple",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.glassBorder,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        TextButton(
          onPressed: () {
            setState(() {
              isLogin = false;
            });
          },
          child: const Text(
            "Don't have an account? Sign up",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.sectionLabel),
        filled: true,
        fillColor: AppColors.inputFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
