import 'package:flutter/material.dart';
import 'package:nikah_app/app_theme.dart';

/// First "basic info" step, right after OTP verification.
/// Muzz asks one thing per screen during onboarding — never a long form —
/// to keep drop-off low and make progress feel fast. This pattern repeats
/// for GenderScreen, BirthdayScreen, LocationScreen, etc. that follow.
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _nameController = TextEditingController();

  // Onboarding progress — update this per-step as you build the rest
  // (Name -> Gender -> Birthday -> Location -> Photos -> Sect -> Intentions).
  static const int _currentStep = 1;
  static const int _totalSteps = 7;

  bool get _canContinue => _nameController.text.trim().length >= 2;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_canContinue) return;
    // TODO: save name to user_model / draft profile, then navigate to
    // GenderScreen.
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _ProgressBar(step: _currentStep, total: _totalSteps)),
                ],
              ),
              const SizedBox(height: 28),
              Text('What\'s your first name?', style: textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'This is how you\'ll appear to others.',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                style: textTheme.bodyLarge,
                decoration: const InputDecoration(hintText: 'First name'),
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue ? _handleContinue : null,
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented progress bar shown across every onboarding step so the user
/// always knows how much is left — Muzz uses this consistently.
class _ProgressBar extends StatelessWidget {
  final int step;
  final int total;

  const _ProgressBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i < step;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
            decoration: BoxDecoration(
              color: filled ? AppColors.emerald : AppColors.roseLight,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}