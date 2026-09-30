import 'package:shared_preferences/shared_preferences.dart';

/// Track karta hai ke user ne koi bhi payment (subscription/premium/fast)
/// ki hai ya nahi — is se poori app mein premium features unlock hote hain
/// jaise Chat option.
class PaidStatusService {
  static const String _key = 'is_paid_user';

  static Future<bool> isPaid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> setPaid(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
