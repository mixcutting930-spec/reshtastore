import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nikah_app/app_theme.dart';

// Profile Model for Firestore Integration
class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String profession;
  final String location;
  final String imageUrl;
  final String sect;
  final String height;
  final bool isVerified;
  final bool isPhotoBlurred;

  ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.profession,
    required this.location,
    required this.imageUrl,
    required this.sect,
    required this.height,
    this.isVerified = true,
    this.isPhotoBlurred = false,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProfileModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      age: data['age'] is int ? data['age'] : int.tryParse(data['age']?.toString() ?? '24') ?? 24,
      profession: data['profession'] ?? 'Not Specified',
      location: data['location'] ?? 'Pakistan',
      imageUrl: data['photoUrl'] ?? data['imageUrl'] ?? 'https://via.placeholder.com/400',
      sect: data['sect'] ?? 'Sunni',
      height: data['height'] ?? "5' 5\"",
      isVerified: data['isVerified'] ?? false,
      isPhotoBlurred: data['isPhotoBlurred'] ?? false,
    );
  }
}

class HomeSwipeScreen extends StatefulWidget {
  // FIXED: Changed 'Key: key' to 'key: key'
  const HomeSwipeScreen({super.key});

  @override
  State<HomeSwipeScreen> createState() => _HomeSwipeScreenState();
}

class _HomeSwipeScreenState extends State<HomeSwipeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ProfileModel> _profiles = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  Offset _cardOffset = Offset.zero;
  bool _isPhotoBlurToggled = false;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  // Fetch profiles from Firestore filtering already swiped ones
  Future<void> _fetchProfiles() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get current user details to determine target gender query
      final userDoc = await _db.collection('users').doc(currentUser.uid).get();
      final userGender = userDoc.data()?['gender'] ?? 'Male';
      final targetGender = userGender == 'Male' ? 'Female' : 'Male';

      // Fetch IDs already liked or passed
      final likedDocs = await _db.collection('users').doc(currentUser.uid).collection('likes').get();
      final passedDocs = await _db.collection('users').doc(currentUser.uid).collection('passes').get();

      final excludedIds = <String>{
        currentUser.uid,
        ...likedDocs.docs.map((d) => d.id),
        ...passedDocs.docs.map((d) => d.id),
      };

      // Fetch potential matches
      final querySnapshot = await _db
          .collection('users')
          .where('gender', isEqualTo: targetGender)
          .limit(20)
          .get();

      final fetched = querySnapshot.docs
          .where((doc) => !excludedIds.contains(doc.id))
          .map((doc) => ProfileModel.fromFirestore(doc))
          .toList();

      setState(() {
        _profiles = fetched;
        _isLoading = false;
        _currentIndex = 0;
      });
    } catch (e) {
      debugPrint("Error fetching profiles: $e");
      setState(() => _isLoading = false);
    }
  }

  // Handle Swipe Action & Update Firestore
  void _onSwipe(bool isLiked) async {
    if (_currentIndex >= _profiles.length) return;

    final targetProfile = _profiles[_currentIndex];
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId != null) {
      if (isLiked) {
        // Record Like
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('likes')
            .doc(targetProfile.id)
            .set({'timestamp': FieldValue.serverTimestamp()});

        // Check if mutual match exists
        final targetLikeDoc = await _db
            .collection('users')
            .doc(targetProfile.id)
            .collection('likes')
            .doc(currentUserId)
            .get();

        if (targetLikeDoc.exists) {
          // Create Match Document
          final matchRef = _db.collection('matches').doc();
          await matchRef.set({
            'users': [currentUserId, targetProfile.id],
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessage': 'You matched with each other!',
            'lastMessageTime': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("🎉 It's a Match with ${targetProfile.name}!"),
                backgroundColor: AppColors.emerald,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          _showToast("Passed Like to ${targetProfile.name}", AppColors.emerald);
        }
      } else {
        // Record Pass
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('passes')
            .doc(targetProfile.id)
            .set({'timestamp': FieldValue.serverTimestamp()});

        _showToast("Passed Profile", AppColors.error);
      }
    }

    setState(() {
      _currentIndex++;
      _cardOffset = Offset.zero;
      _isPhotoBlurToggled = false;
    });
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 600),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: AppColors.emerald, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "MuzzNikah",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: AppFonts.medium,
                        fontWeight: FontWeight.bold,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppColors.textDark),
                  onPressed: () {
                    // Filter BottomSheet integration point
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
            : _currentIndex >= _profiles.length
            ? _buildEmptyState()
            : Stack(
          alignment: Alignment.center,
          children: [
            // Background Stack Card
            if (_currentIndex + 1 < _profiles.length)
              Positioned(
                top: 15,
                child: Transform.scale(
                  scale: 0.94,
                  child: _buildProfileCard(
                    _profiles[_currentIndex + 1],
                    size,
                    isFrontCard: false,
                  ),
                ),
              ),

            // Active Interactive Front Card
            Positioned(
              top: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _cardOffset += details.delta;
                  });
                },
                onPanEnd: (details) {
                  if (_cardOffset.dx > 120) {
                    _onSwipe(true);
                  } else if (_cardOffset.dx < -120) {
                    _onSwipe(false);
                  } else {
                    setState(() {
                      _cardOffset = Offset.zero;
                    });
                  }
                },
                child: Transform.translate(
                  offset: _cardOffset,
                  child: Transform.rotate(
                    angle: _cardOffset.dx / 1000,
                    child: _buildProfileCard(
                      _profiles[_currentIndex],
                      size,
                      isFrontCard: true,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Floating Controls
            Positioned(
              bottom: 25,
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  // Card UI Component
  Widget _buildProfileCard(ProfileModel profile, Size size, {required bool isFrontCard}) {
    final double cardWidth = size.width * 0.92;
    final double cardHeight = size.height * 0.68;
    final bool shouldBlur = profile.isPhotoBlurred || _isPhotoBlurToggled;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // FIXED: withValues
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              profile.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.roseLight,
                child: const Icon(Icons.person, size: 80, color: AppColors.textMuted),
              ),
            ),
            if (shouldBlur)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                // FIXED: withValues
                child: Container(color: Colors.black.withValues(alpha: 0.2)),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // FIXED: withValues
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildChip(profile.sect, Icons.mosque_rounded),
                  if (isFrontCard)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPhotoBlurToggled = !_isPhotoBlurToggled;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          // FIXED: withValues
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              shouldBlur ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              shouldBlur ? "Blurred" : "Visible",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "${profile.name}, ${profile.age}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (profile.isVerified)
                        const Icon(Icons.verified_rounded, color: Color(0xFF4CAF50), size: 22),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(profile.profession, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text("${profile.location} • ${profile.height}",
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(
          icon: Icons.close_rounded,
          iconColor: AppColors.error,
          onTap: () => _onSwipe(false),
          size: 60,
        ),
        const SizedBox(width: 20),
        _buildCircleButton(
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
          onTap: () => _onSwipe(true),
          size: 50,
        ),
        const SizedBox(width: 20),
        _buildCircleButton(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.emerald,
          onTap: () => _onSwipe(true),
          size: 60,
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required double size,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // FIXED: withValues
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // FIXED: withValues
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // FIXED: withValues
          Icon(Icons.style_outlined, size: 80, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            "No More Profiles Right Now",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try broadening your search filters to find more matches.",
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchProfiles();
            },
            child: const Text("Refresh Profiles", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}