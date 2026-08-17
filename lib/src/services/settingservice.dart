import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:landpage/src/ui/custom/loading.dart';
import 'package:landpage/src/ui/custom/toast.dart';
import 'package:landpage/src/utils/colors.dart';

class SettingsService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Re-authenticates the current user with their existing password.
  /// Required by Firebase before sensitive actions like updateEmail,
  /// updatePassword, or delete — otherwise those calls throw
  /// `requires-recent-login`.
  Future<bool> _reauthenticate({
    required BuildContext context,
    required String currentPassword,
  }) async {
    final user = auth.currentUser;

    if (user == null || user.email == null) {
      showSnackBar(context, "No signed-in user found.");
      return false;
    }

    if (currentPassword.trim().isEmpty) {
      showSnackBar(context, "Please enter your current password.");
      return false;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = "Incorrect password.";
          break;
        case 'too-many-requests':
          message = "Too many attempts. Please try again later.";
          break;
        case 'network-request-failed':
          message = "Please check your internet connection.";
          break;
        default:
          message = e.message ?? "Re-authentication failed.";
      }
      if (!context.mounted) return false;
      showSnackBar(context, message);
      return false;
    } catch (e) {
      if (!context.mounted) return false;
      showSnackBar(context, "Unexpected Error: $e");
      return false;
    }
  }

  Future<void> updateEmail({
    required BuildContext context,
    required String currentPassword,
    required String newEmail,
  }) async {
    if (newEmail.trim().isEmpty) {
      showSnackBar(context, "Please enter a new email.");
      return;
    }

    if (!newEmail.contains('@')) {
      showSnackBar(context, "Please enter a valid email.");
      return;
    }

    final reauthed = await _reauthenticate(
      context: context,
      currentPassword: currentPassword,
    );
    if (!reauthed) return;
    if (!context.mounted) return;

    try {
      final user = auth.currentUser;

      // verifyBeforeUpdateEmail sends a confirmation link to the NEW
      // address and only swaps the email once the user clicks it —
      // this is required on modern Firebase Auth (updateEmail() alone
      // is deprecated/blocked for unverified flows).
      await user?.verifyBeforeUpdateEmail(newEmail.trim());

      if (!context.mounted) return;

      showSnackBar(
        context,
        "Verification link sent to $newEmail. Confirm it to complete the change.",
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;
        case 'email-already-in-use':
          message = "This email is already in use by another account.";
          break;
        case 'requires-recent-login':
          message = "Please log in again and retry.";
          break;
        case 'network-request-failed':
          message = "Please check your internet connection.";
          break;
        default:
          message = e.message ?? "Could not update email.";
      }
      if (!context.mounted) return;
      showSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, "Unexpected Error: $e");
    }
  }

  Future<void> updatePassword({
    required BuildContext context,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.trim().isEmpty) {
      showSnackBar(context, "Please enter a new password.");
      return;
    }

    if (newPassword.trim().length < 6) {
      showSnackBar(context, "Password must be at least 6 characters.");
      return;
    }

    final reauthed = await _reauthenticate(
      context: context,
      currentPassword: currentPassword,
    );
    if (!reauthed) return;
    if (!context.mounted) return;

    try {
      await auth.currentUser?.updatePassword(newPassword.trim());

      if (!context.mounted) return;

      showSnackBar(context, "Password updated successfully.");
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = "Please choose a stronger password.";
          break;
        case 'requires-recent-login':
          message = "Please log in again and retry.";
          break;
        case 'network-request-failed':
          message = "Please check your internet connection.";
          break;
        default:
          message = e.message ?? "Could not update password.";
      }
      if (!context.mounted) return;
      showSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, "Unexpected Error: $e");
    }
  }

  Future<void> deleteAccount({
    required BuildContext context,
    required String currentPassword,
    required Widget registerPage,
  }) async {
    final reauthed = await _reauthenticate(
      context: context,
      currentPassword: currentPassword,
    );
    if (!reauthed) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.deleteAccountBarrier,
      builder: (_) => const LoadingOverlay(message: "Deleting your account..."),
    );

    try {
      await auth.currentUser?.delete();

      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      // Close the loading overlay first
      Navigator.of(context, rootNavigator: true).pop();

      // Then send them to the register/login page, clearing history
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => registerPage),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      // Close the loading overlay before showing the error
      Navigator.of(context, rootNavigator: true).pop();

      String message;
      switch (e.code) {
        case 'requires-recent-login':
          message = "Please log in again and retry.";
          break;
        case 'network-request-failed':
          message = "Please check your internet connection.";
          break;
        default:
          message = e.message ?? "Could not delete account.";
      }

      if (!context.mounted) return;
      showSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (!context.mounted) return;
      showSnackBar(context, "Unexpected Error: $e");
    }
  }
}