import 'package:shared_preferences/shared_preferences.dart';

/// Track karta hai ke konse rishtay unlock ho gaye hain (payment ke baad).
/// Isse dobara payment nahi karni parti agar pehle se unlock hai.
class UnlockService {
  static const String _key = 'unlocked_rishtay';

  static Future<Set<String>> getUnlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  static Future<void> unlock(String rishtaId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (!list.contains(rishtaId)) {
      list.add(rishtaId);
      await prefs.setStringList(_key, list);
    }
  }

  static Future<bool> isUnlocked(String rishtaId) async {
    final ids = await getUnlockedIds();
    return ids.contains(rishtaId);
  }
}
