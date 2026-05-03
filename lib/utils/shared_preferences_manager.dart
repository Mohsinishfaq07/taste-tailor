import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserRole = 'userRole';
  static const String keyUserImage = 'userImage';

  // Save user session
  static Future<void> saveUserSession({
    required String userId,
    required String name,
    required String email,
    required String role,
    String? image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserId, userId);
    await prefs.setString(keyUserName, name);
    await prefs.setString(keyUserEmail, email);
    await prefs.setString(keyUserRole, role);
    if (image != null) {
      await prefs.setString(keyUserImage, image);
    }
  }

  // Get user session
  static Future<Map<String, dynamic>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool(keyIsLoggedIn) ?? false,
      'userId': prefs.getString(keyUserId),
      'userName': prefs.getString(keyUserName),
      'userEmail': prefs.getString(keyUserEmail),
      'userRole': prefs.getString(keyUserRole),
      'userImage': prefs.getString(keyUserImage),
    };
  }

  // Clear user session
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Individual getters
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserRole);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId);
  }
}
