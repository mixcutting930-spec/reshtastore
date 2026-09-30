import 'package:shared_preferences/shared_preferences.dart';

/// Rishta requests track karta hai — kis rishta ko "Send Request" kiya,
/// aur kis ne "Accept" kiya. Ye sab local storage mein rehta hai.
///
/// NOTE: "Received Request" ke liye asal mein doosre real users ki taraf se
/// aana chahiye — is ke liye Firestore backend chahiye. Filhal demo ke liye
/// kuch entries manually dikhai ja sakti hain.
class RequestService {
  static const String _sentKey = 'sent_requests';
  static const String _acceptedKey = 'accepted_requests';

  static Future<Set<String>> getSentIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_sentKey) ?? []).toSet();
  }

  static Future<void> sendRequest(String rishtaId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_sentKey) ?? [];
    if (!list.contains(rishtaId)) {
      list.add(rishtaId);
      await prefs.setStringList(_sentKey, list);
    }
  }

  static Future<bool> isSent(String rishtaId) async {
    final ids = await getSentIds();
    return ids.contains(rishtaId);
  }

  static Future<Set<String>> getAcceptedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_acceptedKey) ?? []).toSet();
  }

  static Future<void> acceptRequest(String rishtaId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_acceptedKey) ?? [];
    if (!list.contains(rishtaId)) {
      list.add(rishtaId);
      await prefs.setStringList(_acceptedKey, list);
    }
  }
}
