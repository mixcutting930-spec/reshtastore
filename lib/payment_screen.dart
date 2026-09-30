import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'rishta_model.dart';
import 'app_theme.dart';
import 'unlock_service.dart';
import 'paid_status_service.dart';

enum PaymentMethod { easypaisa, jazzcash }

class PaymentScreen extends StatefulWidget {
  // Rishta ka contact unlock karna ho to ye pass karen
  final RishtaModel? rishta;

  // Premium/Fast service jaisi generic payment ke liye
  final int? customFeeAmount;
  final String? serviceTitle;
  final String? serviceDescription;

  const PaymentScreen({
    super.key,
    this.rishta,
    this.customFeeAmount,
    this.serviceTitle,
    this.serviceDescription,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isSubmitting = false;
  File? paymentScreenshot;
  PaymentMethod selectedMethod = PaymentMethod.easypaisa;

  // Agar customFeeAmount diya hai (Premium/Fast) to wo use hoga,
  // warna normal rishta unlock fee (2200)
  late final int feeAmount = widget.customFeeAmount ?? 2200;

  // Company/App account details
  final String easypaisaTitle = 'SAHAR';
  final String easypaisaNumber = '0344-9154043';

  final String jazzcashTitle = 'SAHAR';
  final String jazzcashNumber = '0344-9154043';

  void copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied!')),
    );
  }

  Future<void> pickPaymentScreenshot(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          paymentScreenshot = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery se select karen'),
                onTap: () {
                  Navigator.pop(context);
                  pickPaymentScreenshot(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Camera se photo len'),
                onTap: () {
                  Navigator.pop(context);
                  pickPaymentScreenshot(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> handlePaymentConfirm() async {
    if (paymentScreenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload payment screenshot first'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (widget.rishta != null) {
      await UnlockService.unlock(widget.rishta!.id);
    }

    await PaidStatusService.setPaid(true);

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Sent'),
        content: Text(
          widget.rishta != null
              ? 'Aapki payment screenshot receive ho gai hai. Verification ke baad contact number unlock ho jayega.'
              : 'Aapki payment screenshot receive ho gai hai. Verification ke baad service activate ho jayegi.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog close
              Navigator.pop(context, true); // payment screen se wapis, success signal
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rishta = widget.rishta;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(
            fontFamily: "Rubik Medium",
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (rishta != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        rishta.imagePath,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 60,
                          width: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rishta.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Rubik Medium",
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${rishta.age} yrs • ${rishta.city} • ${rishta.profession}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.primary, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceTitle ?? 'Service',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Rubik Medium",
                              color: AppColors.textDark,
                            ),
                          ),
                          if (widget.serviceDescription != null)
                            Text(
                              widget.serviceDescription!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Fee/Price card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rishta != null ? 'Unlock Fee' : 'Service Fee',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Rubik Medium",
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'PKR $feeAmount',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Rubik Medium",
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              rishta != null
                  ? 'Send payment to unlock full details'
                  : 'Send payment to activate this service',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "Rubik Medium",
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildMethodTab(label: 'EasyPaisa', method: PaymentMethod.easypaisa),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMethodTab(label: 'JazzCash', method: PaymentMethod.jazzcash),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSelectedAccountCard(),

            const SizedBox(height: 24),

            const Text(
              'Upload Payment Screenshot',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "Rubik Medium",
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: showImageSourceOptions,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: paymentScreenshot == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload screenshot',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                )
                    : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        paymentScreenshot!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            paymentScreenshot = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'PKR $feeAmount ki payment karne ke baad screenshot upload karen aur "I Have Paid" button par click karen. Verification ke baad admin aap ko approve kar dega.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: isSubmitting ? null : handlePaymentConfirm,
                child: Container(
                  height: 45,
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'I Have Paid',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTab({required String label, required PaymentMethod method}) {
    final bool isSelected = selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedAccountCard() {
    switch (selectedMethod) {
      case PaymentMethod.easypaisa:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffE8F6EA),
            border: Border.all(color: const Color(0xff2FAE4A)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.phone_android, color: Color(0xff2FAE4A)),
                  SizedBox(width: 8),
                  Text(
                    'EasyPaisa',
                    style: TextStyle(
                      fontFamily: "Rubik Medium",
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2FAE4A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildAccountRow('Account Title', easypaisaTitle),
              const Divider(),
              _buildAccountRow('EasyPaisa Number', easypaisaNumber),
            ],
          ),
        );

      case PaymentMethod.jazzcash:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffFDE9EC),
            border: Border.all(color: const Color(0xffE0146E)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.phone_android, color: Color(0xffE0146E)),
                  SizedBox(width: 8),
                  Text(
                    'JazzCash',
                    style: TextStyle(
                      fontFamily: "Rubik Medium",
                      fontWeight: FontWeight.bold,
                      color: Color(0xffE0146E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildAccountRow('Account Title', jazzcashTitle),
              const Divider(),
              _buildAccountRow('JazzCash Number', jazzcashNumber),
            ],
          ),
        );
    }
  }

  Widget _buildAccountRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
          onPressed: () => copyToClipboard(value, label),
        ),
      ],
    );
  }
}