/*
 * File Name   : preferences_helper.dart
 * Description : SharedPreferences manager for user settings and login state.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _keyDarkMode = 'isDarkMode';
  static const String _keyLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';

  /*
   * Save dark mode preference
   * Parameters: isDark - Boolean indicating dark mode state
   */
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  /*
   * Get dark mode preference
   * Returns: Boolean indicating if dark mode is enabled (default: false)
   */
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  /*
   * Save login state
   * Parameters: isLoggedIn - Boolean indicating login status
   */
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, isLoggedIn);
  }

  /*
   * Get login state
   * Returns: Boolean indicating if user is logged in (default: false)
   */
  static Future<bool> getLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /*
   * Save user email for autofill
   * Parameters: email - User's email address
   */
  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  /*
   * Get saved user email
   * Returns: User's email or empty string if not saved
   */
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail) ?? '';
  }

  /*
   * Clear all user data (logout)
   */
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyUserEmail);
  }

  /*
   * Clear all preferences (reset app)
   */
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
