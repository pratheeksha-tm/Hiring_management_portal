import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:landpage/src/ui/custom/loading.dart';
import 'package:landpage/src/ui/custom/toast.dart';
import 'package:landpage/src/ui/screens/admin.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> loginUser({
    required BuildContext context,
    required TextEditingController loginEmailController,
    required TextEditingController loginPasswordController,
    required Widget dashboardPage,
  }) async {
    if (loginEmailController.text.trim().isEmpty) {
      showSnackBar(context, "Please enter your email.");
      return;
    }

    if (!loginEmailController.text.contains('@')) {
      showSnackBar(context, "Please enter a valid email.");
      return;
    }

    if (loginPasswordController.text.trim().isEmpty) {
      showSnackBar(context, "Please enter your password.");
      return;
    }

    // if (loginEmailController.text.trim() == 'ppratheeksha094@gmail.com' &&
    //     loginPasswordController.text.trim() == 'Admin@12') {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
    //   );

    //   loginEmailController.clear();
    //   loginPasswordController.clear();

    //   return;
    // }

    try {
      UserCredential user = await auth.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      await user.user?.reload();
      User? currentUser = auth.currentUser;

      if (currentUser != null &&
          currentUser.email == 'ppratheeksha094@gmail.com') {
        if (!context.mounted) return;

        loginEmailController.clear();
        loginPasswordController.clear();
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.35),
          builder: (_) => const LoadingOverlay(),
        );
        await Future.delayed(const Duration(milliseconds: 1200));
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
        return;
      }

      if (currentUser != null && !currentUser.emailVerified) {
        await auth.signOut();

        if (!context.mounted) return;

        showSnackBar(context, "Please verify your email before logging in.");

        return;
      }

      if (!context.mounted) return;

      // showSnackBar(context, "Login Successful! Redirecting ...");

      loginEmailController.clear();
      loginPasswordController.clear();

      // Show loading overlay on TOP of the current (login) page
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.35),
        builder: (_) => const LoadingOverlay(),
      );

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!context.mounted) return;

      // Close the overlay dialog first
      Navigator.of(context, rootNavigator: true).pop();

      // Then go to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => dashboardPage),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;

        case 'invalid-credential':
          message = "Invalid email or password.";
          break;

        case 'user-not-found':
          message = "No account found with this email.";
          break;

        case 'wrong-password':
          message = "Incorrect password.";
          break;

        case 'user-disabled':
          message = "This account has been disabled.";
          break;

        case 'network-request-failed':
          message = "Please check your internet connection.";
          break;

        case 'too-many-requests':
          message = "Too many attempts. Please try again later.";
          break;

        default:
          message = e.message ?? "Login failed.";
      }

      if (!context.mounted) return;

      showSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;

      showSnackBar(context, "Unexpected Error: $e");
    }
  }

  Future<void> resetPassword({
    required BuildContext context,
    required TextEditingController emailController,
  }) async {
    if (emailController.text.trim().isEmpty) {
      showSnackBar(context, "Please enter your email first!");
      return;
    }

    if (!emailController.text.contains('@')) {
      showSnackBar(context, "Please enter a valid email.");
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email: emailController.text.trim());

      if (!context.mounted) return;

      showSnackBar(
        context,
        "Password reset email has been sent. Check your inbox.",
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = "Invalid email address.";
          break;

        case 'user-not-found':
          message = "No account found with this email.";
          break;

        case 'network-request-failed':
          message = "Check your internet connection.";
          break;

        case 'too-many-requests':
          message = "Too many requests. Try again later.";
          break;

        default:
          message = e.message ?? "Something went wrong.";
      }

      if (!context.mounted) return;

      showSnackBar(context, message);
    }
  }

  Future<void> logoutUser({
    required BuildContext context,
    required Widget registerPage,
  }) async {
    // Navigate immediately — dashboard is gone before auth state changes.
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LoadingOverlay(message: "Logging you out..."),
    );

    await Future.delayed(const Duration(milliseconds: 700));

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => registerPage),
      (route) => false,
    );

    // Sign out after navigation, no UI depends on it anymore.
    try {
      await auth.signOut();
    } catch (e) {
      // optionally log this, but don't block/react in UI since we've already left
    }
  }
}
