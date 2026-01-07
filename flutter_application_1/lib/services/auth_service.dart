import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../fcm_service.dart';

class AuthService {
  /// ===================== LOGIN =====================
  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      // Get DEVICE token ONLY for login request
      final deviceFcmToken = await FcmService.instance.getToken();

      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobile": username,
          "password": password,
          "fcm_token": deviceFcmToken,
          "timezone": "Asia/Kolkata",
        }),
      );

      if (response.statusCode != 200) {
        return "Server error";
      }

      final data = jsonDecode(response.body);
      final userInfo = data["user_info"]?[0];

      if (userInfo == null || userInfo["response_code"] != 1) {
        return userInfo?["response_message"] ?? "Login failed";
      }

      final prefs = await SharedPreferences.getInstance();

      // ✅ CRITICAL: SERVER RETURNED FCM TOKEN (THIS IS SESSION KEY)
      final serverFcmToken = userInfo["fcm_token"]?.toString() ?? "";
      if (serverFcmToken.isEmpty) {
        return "Server error: Missing FCM token";
      }

      // ================= SAVE EVERYTHING BACKEND NEEDS =================
      await prefs.setInt("uid", int.parse(userInfo["uid"].toString()));
      await prefs.setString("login_password", password);
      await prefs.setString("login_fcm_token", serverFcmToken);

      await prefs.setString("db_name", userInfo["db_name"] ?? "");
      await prefs.setString("dir_name", userInfo["dir_name"] ?? "");

      // Optional but backend-dependent (safe to store)
      await prefs.setString("client_id", userInfo["client_id"]?.toString() ?? "");
      await prefs.setString("time_zone", userInfo["time_zone"] ?? "Asia/Kolkata");
      await prefs.setString("currancy", userInfo["currancy"] ?? "INR");

      // Store full object only for UI use
      await prefs.setString("user_info", jsonEncode(userInfo));

      print("✅ LOGIN SUCCESS — AUTH DATA SAVED");
      print("UID: ${userInfo["uid"]}");
      print("FCM (server): ${serverFcmToken.substring(0, 20)}...");

      return null;
    } catch (e) {
      print("❌ Login error: $e");
      return "Something went wrong";
    }
  }

  /// ===================== AUTH PAYLOAD (USED BY ALL APIs) =====================
  static Future<Map<String, dynamic>?> getAuthPayload() async {
    final prefs = await SharedPreferences.getInstance();

    final uid = prefs.getInt("uid");
    final password = prefs.getString("login_password");
    final fcmToken = prefs.getString("login_fcm_token");
    final dbName = prefs.getString("db_name");
    final dirName = prefs.getString("dir_name");

    if (uid == null ||
        password == null ||
        fcmToken == null ||
        fcmToken.isEmpty ||
        dbName == null ||
        dirName == null) {
      print("❌ AUTH PAYLOAD INVALID — Missing stored credentials");
      return null;
    }

    final payload = {
      "uid": uid,
      "password": password,
      "fcm_token": fcmToken,
      "db_name": dbName,
      "dir_name": dirName,
    };

    print("📤 AUTH PAYLOAD:");
    print(payload);

    return payload;
  }

  /// ===================== LOGOUT =====================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final payload = await getAuthPayload();
      if (payload != null) {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );
        print("✅ Logout API hit");
      }
    } catch (e) {
      print("⚠️ Logout API failed: $e");
    }

    await prefs.clear();
    await FcmService.instance.clearToken();
    print("🧹 Local logout complete");
  }

  /// ===================== CHECK LOGIN =====================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("uid") &&
        prefs.containsKey("login_fcm_token");
  }
}
