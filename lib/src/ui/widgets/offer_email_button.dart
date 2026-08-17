import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:landpage/src/ui/screens/applications_section.dart' show ApplicationData, ApplicationStatus;

class OfferEmailButton extends StatefulWidget {
  final ApplicationData data;
  final bool alreadySent;     
  final VoidCallback onSent;  

  const OfferEmailButton({
    super.key,
    required this.data,
    required this.alreadySent,
    required this.onSent,
  });

  @override
  State<OfferEmailButton> createState() => _OfferEmailButtonState();
}

class _OfferEmailButtonState extends State<OfferEmailButton> {
  bool _sending = false;

 
  static const String _serviceId = 'service_zi7ss9u';
  static const String _templateId = 'template_ajnrgvj';
  static const String _publicKey = 'YPvHkFcr4kbga-rep';

  Future<void> _sendOfferEmail() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No signed-in user email found.")),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': email,
            'role': widget.data.role,
            'company': widget.data.company,
            'applied_on': widget.data.appliedOn,
          },
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _sending = false);
        widget.onSent(); // tell the parent so it persists across filter changes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offer email sent successfully!")),
        );
      } else {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send email (${response.statusCode}): ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending email: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show for "offer" status — hidden for everything else.
    if (widget.data.status != ApplicationStatus.offer) {
      return const SizedBox.shrink();
    }

    final bool sent = widget.alreadySent; // comes from parent, not local
    final bool disabled = _sending || sent;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 34,
        child: ElevatedButton.icon(
          onPressed: disabled ? null : _sendOfferEmail,
          icon: _sending
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(
                  sent ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.mail_solid,
                  size: 15,
                  color: Colors.white,
                ),
          label: Text(
            _sending ? "Sending..." : (sent ? "Sent" : "Offer"),
            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: sent ? Colors.grey.shade600 : const Color.fromARGB(255, 133, 220, 165),
            foregroundColor: Colors.white,
            disabledBackgroundColor: sent ? Colors.grey.shade600 : Colors.grey.shade700,
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}