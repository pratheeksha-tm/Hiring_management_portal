import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:landpage/src/ui/screens/admin.dart';
import 'package:landpage/src/ui/screens/dashboard.dart';
import '../../../main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // still checking, show a loading spinner briefly
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          if (snapshot.data!.email == 'ppratheeksha094@gmail.com') {
            return const AdminDashboardPage();
          }
          return const DashboardPage();
        }

        return const LandingPage();
      },
    );
  }
}
