import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';

/// Forgot Password dialog — email par reset link bhejta hai,
/// aur "Resend" button par 60 second ka countdown dikhata hai
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController emailController = TextEditingController();

  bool isSending = false;
  bool linkSent = false;
  int secondsRemaining = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      secondsRemaining = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            secondsRemaining = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            secondsRemaining--;
          });
        }
      }
    });
  }

  Future<void> _sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        isSending = false;
        linkSent = true;
      });

      _startCountdown();
    } on FirebaseAuthException catch (e) {
      String message = 'Kuch masla ho gaya, dobara try karen';
      if (e.code == 'user-not-found') {
        message = 'Is email se koi account nahi mila';
      } else if (e.code == 'invalid-email') {
        message = 'Sahi email address likhen';
      }

      if (!mounted) return;
      setState(() {
        isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = !isSending && secondsRemaining == 0;

    return AlertDialog(
      title: const Text('Password Reset'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apna email likhen, hum reset link bhej denge.',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 4),
          const Text(
            '(Email na mile to Spam/Junk folder zaroor check karen)',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !linkSent || secondsRemaining == 0,
            decoration: InputDecoration(
              hintText: 'Email',
              fillColor: AppColors.fieldFill,
              filled: true,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (linkSent) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    secondsRemaining > 0
                        ? 'Link bhej diya gaya hai. Dobara bhejne ke liye $secondsRemaining second wait karen.'
                        : 'Link nahi mila? Dobara bhej saken hain.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: canSend ? _sendResetLink : null,
          child: isSending
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  !linkSent
                      ? 'Send Link'
                      : (secondsRemaining > 0
                          ? 'Resend (${secondsRemaining}s)'
                          : 'Resend Link'),
                  style: TextStyle(
                    color: canSend ? AppColors.primary : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
