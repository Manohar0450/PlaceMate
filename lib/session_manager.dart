import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages login state across app restarts.
/// Call [saveSession] on login, [clearSession] on logout.
/// Use [isLoggedIn] + [getSavedRole] in SplashScreen to redirect.
class SessionManager {
  static const _keyUserData = 'user_data';
  static const _keyRole = 'user_role';
  static const _keyUserId = 'user_id';

  // ── SAVE ──────────────────────────────────────────────────────────────────

  static Future<void> saveSession({
    required Map<String, dynamic> userData,
    required String role,   // "principal" | "coordinator" | "student"
    required String userId, // _id for principal/coordinator, rollId for student
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(userData));
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyUserId, userId);
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyRole);
  }

  static Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<Map<String, dynamic>?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserData);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── UPDATE (called after profile edit) ───────────────────────────────────

  static Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(updatedData));
  }

  // ── CLEAR (logout) ────────────────────────────────────────────────────────

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
  }
}