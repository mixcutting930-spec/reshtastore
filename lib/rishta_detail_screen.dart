import 'package:flutter/material.dart';
import 'rishta_model.dart';
import 'app_theme.dart';
import 'unlock_service.dart';
import 'subscription_screen.dart';
import 'request_service.dart';
import 'paid_status_service.dart';
import 'chat_screen.dart';

class RishtaDetailScreen extends StatefulWidget {
  final RishtaModel rishta;

  const RishtaDetailScreen({super.key, required this.rishta});

  @override
  State<RishtaDetailScreen> createState() => _RishtaDetailScreenState();
}

class _RishtaDetailScreenState extends State<RishtaDetailScreen> {
  bool isUnlocked = false;
  bool isLoading = true;
  bool isRequestSent = false;
  bool isPaidUser = false;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  Future<void> _checkUnlockStatus() async {
    final unlocked = await UnlockService.isUnlocked(widget.rishta.id);
    final sent = await RequestService.isSent(widget.rishta.id);
    final paid = await PaidStatusService.isPaid();
    if (mounted) {
      setState(() {
        isUnlocked = unlocked;
        isRequestSent = sent;
        isPaidUser = paid;
        isLoading = false;
      });
    }
  }

  Future<void> _sendRequest() async {
    await RequestService.sendRequest(widget.rishta.id);
    if (mounted) {
      setState(() {
        isRequestSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request bhej di gai hai')),
      );
    }
  }

  void _openChat() {
    if (!isPaidUser) {
      _showUpgradeDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(rishta: widget.rishta)),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Color(0xffF5A623)),
            SizedBox(width: 8),
            Text('Upgrade Your Account'),
          ],
        ),
        content: const Text(
          'Chat feature unlock karne ke liye apna account upgrade karen. '
          'Payment ke baad aap seedha rishtay se baat kar sakenge.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Baad mein'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionScreen(rishta: widget.rishta),
                ),
              ).then((_) => _checkUnlockStatus());
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  void _goToSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(rishta: widget.rishta),
      ),
    ).then((_) {
      // Wapis aane par unlock status dobara check kar len
      _checkUnlockStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rishta = widget.rishta;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bari picture
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    child: Image.asset(
                      rishta.imagePath,
                      height: 340,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 340,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 80, color: Colors.white),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rishta.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: "Rubik Medium",
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${rishta.age} yrs \u2022 ${rishta.city}',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rishta.profession,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 20),

                        const Text(
                          'Contact Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Rubik Medium",
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.call, color: AppColors.success),
                                const SizedBox(width: 12),
                                Text(
                                  rishta.contactNumber,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lock, color: Colors.grey.shade500),
                                    const SizedBox(width: 12),
                                    Text(
                                      '03XX-XXXXXXX',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _goToSubscription,
                                child: Container(
                                  height: 48,
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
                                  child: const Center(
                                    child: Text(
                                      'Unlock Contact \u2022 PKR 2200',
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
                        const SizedBox(height: 24),

                        // Send Request aur Chat buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isRequestSent ? null : _sendRequest,
                                icon: Icon(
                                  isRequestSent ? Icons.check : Icons.send,
                                  size: 18,
                                ),
                                label: Text(isRequestSent ? 'Request Sent' : 'Send Request'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  foregroundColor: isRequestSent
                                      ? AppColors.success
                                      : AppColors.primary,
                                  side: BorderSide(
                                    color: isRequestSent
                                        ? AppColors.success
                                        : AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _openChat,
                                icon: Icon(
                                  isPaidUser ? Icons.chat_bubble : Icons.lock,
                                  size: 18,
                                ),
                                label: const Text('Chat'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
