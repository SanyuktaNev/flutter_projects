import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/calls.json');
  }

  // Save a new call
  static Future<void> saveCall(Map<String, dynamic> callData) async {
    final file = await _getFile();

    List<Map<String, dynamic>> calls = [];

    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        calls = List<Map<String, dynamic>>.from(jsonDecode(content));
      }
    }

    calls.add(callData);
    await file.writeAsString(jsonEncode(calls));
  }

  // Load all calls
  static Future<List<Map<String, dynamic>>> loadCalls() async {
    final file = await _getFile();

    if (!await file.exists()) return [];

    String content = await file.readAsString();
    if (content.isEmpty) return [];

    return List<Map<String, dynamic>>.from(jsonDecode(content));
  }
}
