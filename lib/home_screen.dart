import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_drawer.dart';
import 'dashboard_screen.dart';
import 'accepted_requests_screen.dart';
import 'sent_requests_screen.dart';
import 'received_requests_screen.dart';
import 'chat_list_screen.dart';
import 'subscription_screen.dart';
import 'profile_screen.dart';
import 'paid_status_service.dart';

/// Login/Profile-setup ke baad ka pehla screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPaidUser = false;

  @override
  void initState() {
    super.initState();
    _loadPaidStatus();
  }

  Future<void> _loadPaidStatus() async {
    final paid = await PaidStatusService.isPaid();
    if (mounted) {
      setState(() {
        isPaidUser = paid;
      });
    }
  }

  void _handleGatedNavigation(Widget targetScreen) {
    if (isPaidUser) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Color(0xffF5A623)),
            SizedBox(width: 8),
            Expanded(child: Text('Upgrade Your Account')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sab features (chat, unlimited requests, full details) unlock '
              'karne ke liye apna account upgrade karen first.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => targetScreen),
                );
              },
              child: const Text('Next'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _goToUpgrade();
              },
              child: const Text(
                'Upgrade Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToUpgrade() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    ).then((_) => _loadPaidStatus());
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        _handleGatedNavigation(const DashboardScreen());
        break;
      case 1:
        // FIX: Import 'chat_list_screen.dart' ke mutabiq ChatListScreen call kiya gaya hai
        _handleGatedNavigation(ChatListScreen());
        break;
      case 2:
        _goToUpgrade();
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rashty Wali',
          style: TextStyle(
            fontFamily: "Rubik Medium",
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Khush Aamdeed!',
              style: TextStyle(
                fontSize: 22,
                fontFamily: "Rubik Medium",
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Apna rishta safar yahan se shuru karen',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.05,
                ),
                children: [
                  _buildCard(
                    icon: Icons.favorite_rounded,
                    color: AppColors.primary,
                    title: 'Perfect Matches',
                    subtitle: 'Behtareen rishtay dekhen',
                    onTap: () => _handleGatedNavigation(const DashboardScreen()),
                  ),
                  _buildCard(
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    title: 'Accepted',
                    subtitle: 'Jo requests accept hui',
                    onTap: () => _handleGatedNavigation(const AcceptedRequestsScreen()),
                  ),
                  _buildCard(
                    icon: Icons.send_rounded,
                    color: const Color(0xff2FAE4A),
                    title: 'Send Request',
                    subtitle: 'Aap ne kise request ki',
                    onTap: () => _handleGatedNavigation(const SentRequestsScreen()),
                  ),
                  _buildCard(
                    icon: Icons.inbox_rounded,
                    color: const Color(0xffF5A623),
                    title: 'Received Request',
                    subtitle: 'Aap ko kis ne request ki',
                    onTap: () => _handleGatedNavigation(const ReceivedRequestsScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Next \u2022 Rishtay Dekhen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: "Rubik Medium",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: _onNavTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(isPaidUser ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium_rounded),
            label: 'Upgrade',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: "Rubik Medium",
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}