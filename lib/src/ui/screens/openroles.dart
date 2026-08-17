import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:landpage/src/ui/screens/company.dart';
import 'package:landpage/src/utils/colors.dart';

class OpenRolesPage extends StatelessWidget {
  const OpenRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildBackButton(context),
                  const SizedBox(height: 24),
                  const CompaniesSection(guestMode: true),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassFill06,
          border: Border.all(color: AppColors.cardGradientStart),
        ),
        child: const Icon(
          CupertinoIcons.back,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}
