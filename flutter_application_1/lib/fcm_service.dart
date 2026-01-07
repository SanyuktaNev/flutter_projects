import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// FCM Service
/// - Generates and caches Firebase Cloud Messaging token
/// - Safe for login/logout cycles
/// - Does NOT break backend validation
/// - Silent and fault-tolerant
class FcmService {
  // Singleton
  static final FcmService instance = FcmService._internal();
  factory FcmService() => instance;
  FcmService._internal();

  static const String _fcmTokenKey = 'fcm_token';

  String? _cachedToken;
  bool _isInitialized = false;

  /// Initialize FCM (call once from main.dart)
  /// Safe to call multiple times
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final messaging = FirebaseMessaging.instance;

      // Request notification permission (iOS dialog, Android auto-granted)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Try loading token from storage first
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString(_fcmTokenKey);

      if (storedToken != null && storedToken.isNotEmpty) {
        _cachedToken = storedToken;
        debugPrint('💾 FCM Token loaded from storage');
      } else {
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          _cachedToken = token;
          await prefs.setString(_fcmTokenKey, token);
          debugPrint('✅ FCM Token generated: ${token.substring(0, 20)}...');
        }
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        _cachedToken = newToken;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, newToken);
        debugPrint('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('⚠️ FCM initialization failed: $e');
      _cachedToken = '';
    }
  }

  /// Get FCM token for API calls
  /// Always returns a valid string (never null)
  Future<String> getToken() async {
    // Use cached token
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken!;
    }

    try {
      // Try loading from storage
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString(_fcmTokenKey);

      if (storedToken != null && storedToken.isNotEmpty) {
        _cachedToken = storedToken;
        return storedToken;
      }

      // Fetch fresh token
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        await prefs.setString(_fcmTokenKey, token);
        return token;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to get FCM token: $e');
    }

    // Fallback (never crash login/logout)
    return '';
  }

  /// Clear FCM token
  /// ⚠️ Call ONLY after backend logout success
  Future<void> clearToken() async {
    try {
      _cachedToken = null;
      _isInitialized = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);

      try {
        await FirebaseMessaging.instance.deleteToken();
        debugPrint('🗑️ FCM Token deleted from Firebase');
      } catch (e) {
        debugPrint('⚠️ Firebase token deletion failed: $e');
      }

      debugPrint('🗑️ FCM Token cleared locally');
    } catch (e) {
      debugPrint('⚠️ Failed to clear FCM token: $e');
    }
  }
}
