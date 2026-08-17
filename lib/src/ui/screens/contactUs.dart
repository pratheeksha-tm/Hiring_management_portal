import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:landpage/src/ui/custom/custom_appbar.dart';
import 'package:landpage/src/ui/custom/toast.dart';
// import 'package:landpage/src/ui/custom/glass_container.dart'; // adjust path if different
import 'package:landpage/src/ui/widgets/glassContainer.dart';
import 'package:landpage/src/utils/colors.dart';
// import 'package:landpage/src/utils/snackbar.dart'; // adjust path to wherever showSnackBar lives
import 'package:landpage/src/utils/app_secrets.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        // Uri.parse(_formspreeEndpoint),
        Uri.parse(AppSecrets.formspreeEndpoint),
        headers: {'Accept': 'application/json'},
        body: {
          'first name': _firstNameController.text.trim(),
          'last name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 202) {
        showSnackBar(context, "Message sent — we'll get back to you soon.");
        _formKey.currentState!.reset();
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        String error = 'Something went wrong. Please try again.';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['errors'] != null) {
            error = body['errors'].toString();
          }
        } catch (_) {}
        showSnackBar(
          context,
          error,
          // color: AppColors.destructive
        );
      }
    } catch (_) {
      if (!mounted) return;
      showSnackBar(
        context,
        'Network error — please check your connection.',
        // color: AppColors.destructive,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('images/land.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBar(isContactPage: true),
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        final left = _ContactInfoColumn(isWide: isWide);
                        final right = ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: GlassContainer(
                            radius: 28,
                            padding: const EdgeInsets.all(28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _LabeledField(
                                          label: 'First Name',
                                          controller: _firstNameController,
                                          hint: 'Enter your first name...',
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                              ? 'Required'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _LabeledField(
                                          label: 'Last Name',
                                          controller: _lastNameController,
                                          hint: 'Enter your last name...',
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                              ? 'Required'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _LabeledField(
                                    label: 'Email',
                                    controller: _emailController,
                                    hint: 'Enter your email address...',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final ok = RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      ).hasMatch(v.trim());
                                      return ok ? null : 'Enter a valid email';
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _LabeledField(
                                    label: 'How can we help you?',
                                    controller: _messageController,
                                    hint: 'Enter your message...',
                                    maxLines: 5,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: 28),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _PillButton(
                                      label: _isSubmitting
                                          ? 'Sending...'
                                          : 'Send Message',
                                      icon: Icons.arrow_forward_rounded,
                                      loading: _isSubmitting,
                                      onTap: _isSubmitting ? null : _submit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: left),
                              const SizedBox(width: 60),
                              Expanded(flex: 5, child: Center(child: right)),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            left,
                            const SizedBox(height: 48),
                            Center(child: right),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoColumn extends StatelessWidget {
  final bool isWide;
  const _ContactInfoColumn({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get in —\ntouch with us',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: isWide ? 44 : 36,
            height: 1.15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 800,
          child: Text(
            "We're here to make your experience as smooth as possible. Whether you have questions about our platform, need help with your account, are "
            "experiencing technical difficulties, or simply want to share your "
            "thoughts and suggestions, our team is happy to help. Don't hesitate to "
            "get in touch—we're just a message away!",
            style: GoogleFonts.poppins(
              color: AppColors.subtitleText,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 36),
        const _InfoBlock(label: 'Email:', value: 'hello@artisan.com'),
        const SizedBox(height: 24),
        const _InfoBlock(
          label: 'Phone:',
          value: '+1 234 567 78',
          caption: 'Available Monday to Friday, 9 AM - 6 PM GMT',
        ),
        const SizedBox(height: 32),
        // _PillButton(
        //   label: 'Live Chat',
        //   icon: Icons.arrow_forward_rounded,
        //   onTap: () {
        //     // TODO: wire up to your live-chat provider (Intercom, Crisp, etc.)
        //   },
        // ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;

  const _InfoBlock({required this.label, required this.value, this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textFaded65,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 6),
          Text(
            caption!,
            style: GoogleFonts.poppins(
              color: AppColors.textFaded50,
              fontSize: 13.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textEmphasis90,
            // color: AppColors.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          cursorColor: AppColors.textPrimary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textFaded40,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.glassBorderHover),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.textPrimary),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.glassBorderHover),
            ),
            errorStyle: GoogleFonts.poppins(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.only(left: 22, right: 6, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: AppColors.accentGradient[1].withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: AppColors.fabGlow.withValues(alpha: 0.5),
                      // blurRadius: 15,
                      spreadRadius: 1,
                      // offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textPrimary,
                ),
                child: widget.loading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentMid,
                        ),
                      )
                    : Icon(widget.icon, color: AppColors.accentMid, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
