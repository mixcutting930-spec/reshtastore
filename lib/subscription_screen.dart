import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'payment_screen.dart';
import 'rishta_model.dart';

class SubscriptionPlan {
  final String label;
  final String duration;
  final int fee;
  final bool isPopular;

  const SubscriptionPlan({
    required this.label,
    required this.duration,
    required this.fee,
    this.isPopular = false,
  });
}

class SubscriptionScreen extends StatelessWidget {
  // Agar kisi khaas rishta ka contact unlock karne ke liye aaye hain,
  // to wo yahan pass hota hai (payment successful hone par wahi unlock hoga)
  final RishtaModel? rishta;

  const SubscriptionScreen({super.key, this.rishta});

  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(label: '1 Month', duration: '30 din', fee: 2200),
    SubscriptionPlan(label: '2 Months', duration: '60 din', fee: 4000),
    SubscriptionPlan(
      label: '3 Months',
      duration: '90 din',
      fee: 6000,
      isPopular: true,
    ),
    SubscriptionPlan(label: '1 Year', duration: '12 mahine', fee: 9999),
    SubscriptionPlan(label: 'Lifetime', duration: 'Hamesha ke liye', fee: 19999),
  ];

  void _selectPlan(BuildContext context, SubscriptionPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          rishta: rishta,
          customFeeAmount: plan.fee,
          serviceTitle: 'Subscription \u2022 ${plan.label}',
          serviceDescription: '${plan.duration} ke liye full access',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Subscription Plans',
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
            const Text(
              'Apna Plan Select Karen',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Rubik Medium",
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Behtareen rishtay dekhne aur contact karne ke liye plan choose karen',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            for (final plan in plans) _buildPlanCard(context, plan),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => _selectPlan(context, plan),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: plan.isPopular
                ? AppColors.primary.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: plan.isPopular ? AppColors.primary : Colors.grey.shade300,
              width: plan.isPopular ? 2 : 1,
            ),
            boxShadow: plan.isPopular
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.label,
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: "Rubik Medium",
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (plan.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.duration,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PKR ${plan.fee}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Rubik Medium",
                      color: plan.isPopular ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: plan.isPopular ? AppColors.primary : Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
