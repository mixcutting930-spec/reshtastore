import 'package:shared_preferences/shared_preferences.dart';

/// Profile picture ka local path save/load karne ke liye
class ProfilePicService {
  static const String _key = 'profile_pic_path';

  /// Image path save karta hai
  static Future<void> savePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
  }

  /// Saved image path wapis lata hai (agar koi na ho to null)
  static Future<String?> getPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Profile picture remove karta hai
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
