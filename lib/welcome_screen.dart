import 'package:flutter/material.dart';
import 'package:nikah_app/app_theme.dart';

/// First screen a user sees. The signature element here is the arch —
/// a direct nod to mihrab/mosque archway silhouettes rather than a generic
/// hero photo or gradient blob, so the design is grounded in the subject
/// (nikah / faith-led marriage) instead of reading as a stock dating app.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _ArchMotif(),
              const SizedBox(height: 40),
              Text(
                'NikkahLink',
                style: textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Marriage, with your family\nin the room.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: navigate to sign up flow
                  },
                  child: const Text('Create an account'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: navigate to login
                  },
                  child: const Text('I already have an account'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'By continuing, you agree to our Terms and\nacknowledge our Privacy Policy.',
                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple arch silhouette built from shapes — no image asset required.
/// Deep emerald arch on ivory, with a thin rose keyline as the one
/// deliberate accent.
class _ArchMotif extends StatelessWidget {
  const _ArchMotif();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 160,
      child: CustomPaint(
        painter: _ArchPainter(),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.emerald
      ..style = PaintingStyle.fill;

    final keylinePaint = Paint()
      ..color = AppColors.roseLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final w = size.width;
    final h = size.height;
    final archRadius = w / 2;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, archRadius)
      ..arcToPoint(
        Offset(w, archRadius),
        radius: Radius.circular(archRadius),
        clockwise: true,
      )
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(path, fillPaint);

    // Inner keyline arch, inset — the one accessorized detail.
    const inset = 16.0;
    final innerRadius = (w - inset * 2) / 2;
    final innerPath = Path()
      ..moveTo(inset, h)
      ..lineTo(inset, archRadius)
      ..arcToPoint(
        Offset(w - inset, archRadius),
        radius: Radius.circular(innerRadius),
        clockwise: true,
      )
      ..lineTo(w - inset, h);

    canvas.drawPath(innerPath, keylinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}