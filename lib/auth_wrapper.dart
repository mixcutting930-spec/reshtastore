import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'app_theme.dart';

/// Ye widget app khulte hi check karta hai ke user pehle se logged in hai ya nahi.
/// Agar logged in hai -> seedha Dashboard
/// Agar nahi -> Login screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase abhi check kar raha hai — branded loading screen dikhayen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _BrandedLoadingScreen();
        }

        // Agar user maujood hai -> already logged in hai
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Warna Login screen dikhayen
        return const LoginScreen();
      },
    );
  }
}

/// Logo + app name ke sath professional loading screen
class _BrandedLoadingScreen extends StatelessWidget {
  const _BrandedLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'images/logo.jpg',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rashty Wali',
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Rubik Medium",
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
