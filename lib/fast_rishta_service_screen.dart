import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'payment_screen.dart';

class FastRishtaServiceScreen extends StatelessWidget {
  const FastRishtaServiceScreen({super.key});

  // Fast service ki extra fee — yahan se aasani se badal sakte hain
  static const int fastServiceFee = 1500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Fast Rishta Service',
          style: TextStyle(
            fontFamily: "Rubik Medium",
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffE8F6EA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xff2FAE4A).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Color(0xff2FAE4A), size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Fast Rishta Service',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: "Rubik Medium",
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jaldi rishta chahiye? Ye service extra priority ke sath '
                    'aap ke profile ko age rakhti hai — jawab aur matches jaldi milte hain.',
                    style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Extra Fee',
                        style: TextStyle(fontSize: 14, color: AppColors.textDark),
                      ),
                      const Text(
                        'PKR $fastServiceFee',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Rubik Medium",
                          color: Color(0xff2FAE4A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(
                            customFeeAmount: fastServiceFee,
                            serviceTitle: 'Fast Rishta Service',
                            serviceDescription: 'Priority matching, jaldi response',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xff2FAE4A),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff2FAE4A).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Get Fast Service \u2022 PKR $fastServiceFee',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Rubik Medium",
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
