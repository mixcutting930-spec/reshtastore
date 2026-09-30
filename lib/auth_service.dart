import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In logic for google_sign_in v6.x
class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google account se sign in karta hai aur Firebase mein bhi login kar deta hai
  /// Successful hone par [User] return karta hai, cancel/fail hone par null
  static Future<User?> signInWithGoogle() async {
    try {
      // Step 1: Google account picker dikhana
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User ne sign-in cancel kar diya
        return null;
      }

      // Step 2: Authentication tokens lena (v6.x mein 'await' lagana hota hai)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Firebase credential banana
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Firebase mein sign in karna
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// Google se sign out karta hai (Firebase se bhi)
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore if not supported
    }
    await FirebaseAuth.instance.signOut();
  }
}