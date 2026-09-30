import 'package:flutter/material.dart';
import 'rishta_model.dart';
import 'request_service.dart';
import 'app_theme.dart';
import 'rishta_detail_screen.dart';

class ReceivedRequestsScreen extends StatefulWidget {
  const ReceivedRequestsScreen({super.key});

  @override
  State<ReceivedRequestsScreen> createState() => _ReceivedRequestsScreenState();
}

class _ReceivedRequestsScreenState extends State<ReceivedRequestsScreen> {
  // NOTE: Ye asal mein Firestore se aana chahiye — jab doosre real users
  // aap ko request bhejen. Filhal demo ke liye 3 profiles dikha rahe hain.
  final List<RishtaModel> receivedRishtay = demoRishtayList.take(3).toList();

  Future<void> _acceptRequest(RishtaModel rishta) async {
    await RequestService.acceptRequest(rishta.id);
    if (mounted) {
      setState(() {
        receivedRishtay.removeWhere((r) => r.id == rishta.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${rishta.name} ki request accept ho gai')),
      );
    }
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
          'Received Request',
          style: TextStyle(
            fontFamily: "Rubik Medium",
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: receivedRishtay.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Filhal koi nayi request nahi hai',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: receivedRishtay.length,
              itemBuilder: (context, index) {
                final rishta = receivedRishtay[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RishtaDetailScreen(rishta: rishta),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            rishta.imagePath,
                            height: 56,
                            width: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 56,
                              width: 56,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
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
                              '${rishta.age} yrs \u2022 ${rishta.city}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _acceptRequest(rishta),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
